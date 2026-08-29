"""Idempotent payment orchestration for fake and Midtrans sandbox providers."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.commerce import AttemptStatus, CheckoutGroup, CheckoutStatus, InventoryReservation, PaymentAttempt, ProductStockAllocation, ReservationStatus
from app.models.operations import Payout, PayoutStatus
from app.models.order import Order, OrderStatus
from app.models.payment import Payment, PaymentPurpose, PaymentStatus
from app.models.product import Product, ProductStatus
from app.models.stock import Stock, StockStatus
from app.models.user import User
from app.services.platform_service import audit, notify, post_ledger
from app.services.providers import payment_provider


class PaymentFlow:
    async def create(
        self, db: AsyncSession, *, payer: User, payee_id: uuid.UUID | None,
        amount: Decimal, purpose: PaymentPurpose, idempotency_key: str,
        order_id: uuid.UUID | None = None, offer_id: uuid.UUID | None = None,
        checkout_group_id: uuid.UUID | None = None, item_name: str = "CropChain",
        commit: bool = True,
    ) -> Payment:
        existing = await db.execute(select(Payment).where(Payment.idempotency_key == idempotency_key).options(selectinload(Payment.attempts)))
        if payment := existing.scalar_one_or_none():
            return payment
        payment = Payment(
            payer_id=payer.id, payee_id=payee_id, amount=amount, purpose=purpose,
            idempotency_key=idempotency_key, order_id=order_id, offer_id=offer_id,
            checkout_group_id=checkout_group_id, midtrans_order_id=f"CC-{uuid.uuid4().hex}",
            status=PaymentStatus.MENUNGGU,
        )
        db.add(payment)
        await db.flush()
        await self._new_attempt(db, payment=payment, payer=payer, item_name=item_name)
        await audit(db, action="payment.created", entity_type="payment", entity_id=payment.id, actor_id=payer.id, metadata={"purpose": purpose.value})
        if commit:
            await db.commit()
            return await self.get(db, payment.id)
        await db.flush()
        return payment

    async def get(self, db: AsyncSession, payment_id: uuid.UUID) -> Payment:
        result = await db.execute(select(Payment).where(Payment.id == payment_id).options(selectinload(Payment.attempts)))
        payment = result.scalar_one_or_none()
        if not payment:
            raise ValueError("Pembayaran tidak ditemukan.")
        return payment

    async def retry(self, db: AsyncSession, *, payment: Payment, payer: User) -> Payment:
        if payment.payer_id != payer.id:
            raise PermissionError("Akses pembayaran ditolak.")
        if payment.status != PaymentStatus.GAGAL:
            raise ValueError("Hanya pembayaran gagal yang dapat dicoba ulang.")
        payment.status = PaymentStatus.MENUNGGU
        await self._new_attempt(db, payment=payment, payer=payer, item_name="Retry CropChain")
        await db.commit()
        return await self.get(db, payment.id)

    async def _new_attempt(self, db: AsyncSession, *, payment: Payment, payer: User, item_name: str) -> PaymentAttempt:
        external_order_id = f"CROPCHAIN-{payment.id}-{uuid.uuid4().hex[:10]}"
        idem = f"attempt-{uuid.uuid4()}"
        session = await payment_provider().create(
            external_order_id=external_order_id, amount=Decimal(str(payment.amount)),
            customer={"first_name": payer.full_name, "email": payer.email}, item_name=item_name,
        )
        attempt = PaymentAttempt(
            payment_id=payment.id, external_order_id=external_order_id,
            idempotency_key=idem, snap_token=session.token, redirect_url=session.redirect_url,
            status=AttemptStatus.PENDING,
        )
        payment.midtrans_order_id = external_order_id
        payment.snap_token = session.token
        payment.snap_redirect_url = session.redirect_url
        db.add(attempt)
        return attempt

    async def transition(self, db: AsyncSession, *, external_order_id: str, outcome: str, actor_id: uuid.UUID | None = None) -> Payment:
        result = await db.execute(
            select(PaymentAttempt).where(PaymentAttempt.external_order_id == external_order_id)
            .options(selectinload(PaymentAttempt.payment)).with_for_update()
        )
        attempt = result.scalar_one_or_none()
        if not attempt:
            raise ValueError("Payment attempt tidak ditemukan.")
        payment = attempt.payment
        if attempt.status in {AttemptStatus.SUCCESS, AttemptStatus.REFUNDED}:
            return payment
        if outcome == "success":
            attempt.status = AttemptStatus.SUCCESS
            payment.status = PaymentStatus.BERHASIL
            payment.paid_at = datetime.now(timezone.utc)
            await self._settle(db, payment)
        elif outcome == "failed":
            attempt.status = AttemptStatus.FAILED
            payment.status = PaymentStatus.GAGAL
            await self._release(db, payment)
        else:
            raise ValueError("Outcome harus success atau failed.")
        await audit(db, action=f"payment.{outcome}", entity_type="payment", entity_id=payment.id, actor_id=actor_id)
        await db.commit()
        return payment

    async def _settle(self, db: AsyncSession, payment: Payment) -> None:
        amount = Decimal(str(payment.amount))
        if payment.purpose == PaymentPurpose.FARMER_OFFER:
            stock_result = await db.execute(select(Stock).where(Stock.offer_id == payment.offer_id).with_for_update())
            stock = stock_result.scalar_one()
            stock.status = StockStatus.ACTIVE
            db.add(Payout(user_id=payment.payee_id, payment_id=payment.id, amount=amount, status=PayoutStatus.PAID, paid_at=datetime.now(timezone.utc)))
            await post_ledger(db, reference_type="farmer_payment", reference_id=payment.id, description="Pembayaran hasil panen", entries=[
                ("gateway_clearing", payment.payer_id, -amount), ("farmer_balance", payment.payee_id, amount),
            ])
            await notify(db, user_id=payment.payee_id, kind="payment", title="Pembayaran hasil panen berhasil", body=f"Rp{amount:,.0f} telah dicatat.")
        else:
            group = await db.get(CheckoutGroup, payment.checkout_group_id)
            if group.status == CheckoutStatus.PAID:
                return
            group.status = CheckoutStatus.PAID
            reservations = await db.execute(select(InventoryReservation).where(InventoryReservation.checkout_group_id == group.id).with_for_update())
            for reservation in reservations.scalars():
                if reservation.status != ReservationStatus.ACTIVE:
                    continue
                product = await db.get(Product, reservation.product_id, with_for_update=True)
                product.stock_reserved = Decimal(str(product.stock_reserved)) - Decimal(str(reservation.quantity))
                product.stock_remaining = Decimal(str(product.stock_remaining)) - Decimal(str(reservation.quantity))
                await self._consume_allocations(db, product.id, Decimal(str(reservation.quantity)))
                if product.stock_remaining <= 0:
                    product.status = ProductStatus.NONAKTIF
                reservation.status = ReservationStatus.COMMITTED
            orders = await db.execute(select(Order).where(Order.checkout_group_id == group.id))
            platform_total = Decimal("0")
            for order in orders.scalars():
                order.status = OrderStatus.DIPROSES
                platform_total += Decimal(str(order.platform_fee))
                revenue = Decimal(str(order.total_price)) - Decimal(str(order.platform_fee))
                await post_ledger(db, reference_type="order_sale", reference_id=order.id, description="Penjualan produk", entries=[
                    ("gateway_clearing", payment.payer_id, -Decimal(str(order.total_price))),
                    ("distributor_revenue", order.distributor_id, revenue),
                    ("platform_revenue", None, Decimal(str(order.platform_fee))),
                ])
                await notify(db, user_id=order.distributor_id, kind="order", title="Pesanan baru dibayar", body=f"Pesanan {order.id} siap diproses.")

    async def _consume_allocations(self, db: AsyncSession, product_id: uuid.UUID, amount: Decimal) -> None:
        result = await db.execute(
            select(ProductStockAllocation).where(ProductStockAllocation.product_id == product_id)
            .order_by(ProductStockAllocation.created_at, ProductStockAllocation.id).with_for_update()
        )
        remaining = amount
        for allocation in result.scalars():
            available = Decimal(str(allocation.allocated_quantity)) - Decimal(str(allocation.consumed_quantity))
            take = min(available, remaining)
            if take <= 0:
                continue
            stock = await db.get(Stock, allocation.stock_id, with_for_update=True)
            allocation.consumed_quantity = Decimal(str(allocation.consumed_quantity)) + take
            stock.quantity_available = Decimal(str(stock.quantity_available)) - take
            stock.quantity_reserved = Decimal(str(stock.quantity_reserved)) - take
            if stock.quantity_available <= 0:
                stock.status = StockStatus.DEPLETED
            remaining -= take
            if remaining <= 0:
                break
        if remaining > 0:
            raise ValueError("Allocation stok tidak cukup untuk settlement.")

    async def _release(self, db: AsyncSession, payment: Payment) -> None:
        if not payment.checkout_group_id:
            return
        group = await db.get(CheckoutGroup, payment.checkout_group_id)
        group.status = CheckoutStatus.FAILED
        reservations = await db.execute(select(InventoryReservation).where(InventoryReservation.checkout_group_id == group.id).with_for_update())
        for reservation in reservations.scalars():
            if reservation.status == ReservationStatus.ACTIVE:
                product = await db.get(Product, reservation.product_id, with_for_update=True)
                product.stock_reserved = Decimal(str(product.stock_reserved)) - Decimal(str(reservation.quantity))
                reservation.status = ReservationStatus.RELEASED


payment_flow = PaymentFlow()
