"""Transactional checkout and order state machine."""
import uuid
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.models.address import Address
from app.models.cart import Cart, CartItem
from app.models.commerce import CheckoutGroup, InventoryReservation, OrderItem, ProductStockAllocation, ReservationStatus
from app.models.operations import Shipment, ShipmentStatus
from app.models.order import Order, OrderStatus, PurchaseMode
from app.models.payment import Payment, PaymentPurpose, PaymentStatus
from app.models.product import Product, ProductStatus
from app.models.stock import Stock, StockStatus
from app.models.user import User
from app.schemas.order import CheckoutItem, CheckoutRequest, CheckoutResponse, OrderResponse
from app.services.payment_flow import payment_flow
from app.services.platform_service import audit, notify, post_ledger
from app.services.providers import payment_provider, shipping_provider

MONEY = Decimal("0.01")


class OrderService:
    async def checkout(self, db: AsyncSession, *, buyer: User, data: CheckoutRequest) -> CheckoutResponse:
        existing = await db.execute(select(CheckoutGroup).where(
            CheckoutGroup.buyer_id == buyer.id, CheckoutGroup.idempotency_key == data.idempotency_key
        ))
        if group := existing.scalar_one_or_none():
            return await self._checkout_response(db, group)

        address = await db.get(Address, data.shipping_address_id)
        if not address or address.user_id != buyer.id:
            raise ValueError("Alamat pengiriman tidak valid.")
        items = await self._resolve_items(db, buyer, data)
        if not items:
            raise ValueError("Checkout tidak memiliki item.")

        products: dict[uuid.UUID, Product] = {}
        grouped: dict[uuid.UUID, list[tuple[CheckoutItem, Product]]] = defaultdict(list)
        for item in items:
            result = await db.execute(select(Product).where(Product.id == item.product_id).with_for_update())
            product = result.scalar_one_or_none()
            if not product or product.status != ProductStatus.AKTIF:
                raise ValueError(f"Produk {item.product_id} tidak aktif atau tidak ditemukan.")
            available = Decimal(str(product.stock_remaining)) - Decimal(str(product.stock_reserved))
            if available < Decimal(str(item.quantity)):
                raise ValueError(f"Stok {product.name} tidak cukup; tersedia {available} kg.")
            product.stock_reserved = Decimal(str(product.stock_reserved)) + Decimal(str(item.quantity))
            products[product.id] = product
            grouped[product.distributor_id].append((item, product))

        expires_at = datetime.now(timezone.utc) + timedelta(minutes=settings.CHECKOUT_RESERVATION_MINUTES)
        group = CheckoutGroup(buyer_id=buyer.id, idempotency_key=data.idempotency_key, expires_at=expires_at)
        db.add(group)
        await db.flush()
        order_models: list[Order] = []
        grand_total = Decimal("0")
        for distributor_id, distributor_items in grouped.items():
            weight = sum((Decimal(str(item.quantity)) for item, _ in distributor_items), Decimal("0"))
            rates = await shipping_provider().rates(
                {"location": distributor_items[0][1].location},
                {"postal_code": address.postal_code, "city": address.city, "latitude": address.latitude, "longitude": address.longitude},
                weight,
            )
            selected_rate_id = data.shipping_rate_ids.get(str(distributor_id))
            rate = next((rate for rate in rates if rate.get("rate_id") == selected_rate_id), rates[0] if rates else None)
            if not rate:
                raise ValueError("Tarif pengiriman tidak tersedia.")
            subtotal = Decimal("0")
            for item, product in distributor_items:
                price = Decimal(str(product.wholesale_price if item.purchase_mode == PurchaseMode.GROSIR else product.public_price))
                subtotal += price * Decimal(str(item.quantity))
            platform_fee = (subtotal * Decimal(str(settings.PLATFORM_FEE_PERCENTAGE)) / Decimal("100")).quantize(MONEY, rounding=ROUND_HALF_UP)
            shipping_fee = Decimal(str(rate["fee"])).quantize(MONEY)
            total = subtotal + platform_fee + shipping_fee
            first_item, first_product = distributor_items[0]
            order = Order(
                checkout_group_id=group.id, buyer_id=buyer.id, distributor_id=distributor_id,
                product_id=first_product.id, shipping_address_id=address.id,
                quantity=sum(item.quantity for item, _ in distributor_items),
                purchase_mode=first_item.purchase_mode, payment_method=data.payment_method,
                total_price=total, shipping_fee=shipping_fee, platform_fee=platform_fee,
                status=OrderStatus.MENUNGGU_PEMBAYARAN,
            )
            db.add(order)
            await db.flush()
            for item, product in distributor_items:
                price = Decimal(str(product.wholesale_price if item.purchase_mode == PurchaseMode.GROSIR else product.public_price))
                db.add(OrderItem(
                    order_id=order.id, product_id=product.id, product_name=product.name,
                    product_photo=product.photo[0] if product.photo else None,
                    quantity=item.quantity, unit_price=price,
                    subtotal=price * Decimal(str(item.quantity)), purchase_mode=item.purchase_mode.value,
                ))
                db.add(InventoryReservation(
                    checkout_group_id=group.id, product_id=product.id,
                    quantity=item.quantity, status=ReservationStatus.ACTIVE, expires_at=expires_at,
                ))
            db.add(Shipment(
                order_id=order.id, provider=settings.SHIPPING_PROVIDER,
                rate_id=rate["rate_id"], courier=rate["courier"], service=rate["service"],
                fee=shipping_fee, status=ShipmentStatus.PENDING, provider_payload={"quote": rate},
            ))
            order_models.append(order)
            grand_total += total

        await payment_flow.create(
            db, payer=buyer, payee_id=None, amount=grand_total,
            purpose=PaymentPurpose.BUYER_ORDER, idempotency_key=f"checkout-{data.idempotency_key}",
            checkout_group_id=group.id, item_name=f"CropChain checkout ({len(order_models)} pesanan)",
            commit=False,
        )
        await audit(db, action="checkout.created", entity_type="checkout_group", entity_id=group.id, actor_id=buyer.id)
        await db.commit()
        return await self._checkout_response(db, group)

    async def _resolve_items(self, db: AsyncSession, buyer: User, data: CheckoutRequest) -> list[CheckoutItem]:
        if data.source == "buy_now":
            return data.items
        result = await db.execute(
            select(CartItem).join(Cart).where(Cart.user_id == buyer.id, CartItem.id.in_(data.cart_item_ids))
        )
        rows = list(result.scalars())
        if len(rows) != len(set(data.cart_item_ids)):
            raise ValueError("Sebagian item cart tidak ditemukan atau bukan milik Anda.")
        return [CheckoutItem(product_id=row.product_id, quantity=float(row.quantity), purchase_mode=PurchaseMode.RETAIL) for row in rows]

    async def _checkout_response(self, db: AsyncSession, group: CheckoutGroup) -> CheckoutResponse:
        orders_result = await db.execute(select(Order).where(Order.checkout_group_id == group.id).options(
            selectinload(Order.items), selectinload(Order.shipping_address), selectinload(Order.distributor), selectinload(Order.payment)
        ).order_by(Order.created_at, Order.id))
        orders = list(orders_result.scalars())
        payment_result = await db.execute(select(Payment).where(Payment.checkout_group_id == group.id))
        payment = payment_result.scalar_one()
        responses = []
        for order in orders:
            response = OrderResponse.model_validate(order)
            response.product_name = order.items[0].product_name if order.items else None
            response.product_photo = order.items[0].product_photo if order.items else None
            response.distributor_name = order.distributor.full_name if order.distributor else None
            responses.append(response)
        return CheckoutResponse(checkout_group_id=group.id, orders=responses, payment=payment, expires_at=group.expires_at)

    async def get_buyer_orders(self, db: AsyncSession, *, buyer: User, status: Optional[OrderStatus] = None, skip: int = 0, limit: int = 50) -> list[OrderResponse]:
        query = select(Order).where(Order.buyer_id == buyer.id).options(selectinload(Order.items), selectinload(Order.shipping_address), selectinload(Order.payment))
        if status:
            query = query.where(Order.status == status)
        result = await db.execute(query.order_by(Order.created_at.desc(), Order.id).offset(skip).limit(limit))
        return [OrderResponse.model_validate(order) for order in result.scalars()]

    async def get_distributor_orders(self, db: AsyncSession, *, distributor: User, status: Optional[OrderStatus] = None, skip: int = 0, limit: int = 50) -> list[OrderResponse]:
        query = select(Order).where(Order.distributor_id == distributor.id).options(selectinload(Order.items), selectinload(Order.shipping_address), selectinload(Order.buyer), selectinload(Order.payment))
        if status:
            query = query.where(Order.status == status)
        result = await db.execute(query.order_by(Order.created_at.desc(), Order.id).offset(skip).limit(limit))
        return [OrderResponse.model_validate(order) for order in result.scalars()]

    async def cancel_order(self, db: AsyncSession, *, order_id: uuid.UUID, buyer: User) -> OrderResponse:
        order = await db.get(Order, order_id, with_for_update=True)
        if not order or order.buyer_id != buyer.id:
            raise PermissionError("Pesanan tidak ditemukan atau bukan milik Anda.")
        if order.status not in {OrderStatus.MENUNGGU_PEMBAYARAN, OrderStatus.DIPROSES}:
            raise ValueError("Pesanan hanya dapat dibatalkan sebelum dikirim.")
        payment_result = await db.execute(select(Payment).where(Payment.checkout_group_id == order.checkout_group_id))
        payment = payment_result.scalar_one_or_none()
        if order.status == OrderStatus.MENUNGGU_PEMBAYARAN:
            product_ids = select(OrderItem.product_id).where(OrderItem.order_id == order.id)
            reservations = await db.execute(select(InventoryReservation).where(
                InventoryReservation.checkout_group_id == order.checkout_group_id,
                InventoryReservation.product_id.in_(product_ids),
                InventoryReservation.status == ReservationStatus.ACTIVE,
            ).with_for_update())
            for reservation in reservations.scalars():
                product = await db.get(Product, reservation.product_id, with_for_update=True)
                product.stock_reserved = max(
                    Decimal("0"),
                    Decimal(str(product.stock_reserved)) - Decimal(str(reservation.quantity)),
                )
                reservation.status = ReservationStatus.RELEASED
        if payment and payment.status == PaymentStatus.BERHASIL:
            payment.status = PaymentStatus.REFUND_PENDING
            ok = await payment_provider().refund(payment.midtrans_order_id, Decimal(str(order.total_price)))
            if not ok:
                payment.status = PaymentStatus.REFUND_FAILED
                await db.commit()
                raise ValueError("Refund provider gagal; pesanan belum dibatalkan.")
            await self.restore_order_inventory(db, order.id)
            await post_ledger(
                db,
                reference_type="order_refund",
                reference_id=order.id,
                description="Refund pesanan",
                entries=[
                    ("gateway_clearing", payment.payer_id, Decimal(str(order.total_price))),
                    (
                        "distributor_revenue",
                        order.distributor_id,
                        -(Decimal(str(order.total_price)) - Decimal(str(order.platform_fee))),
                    ),
                    ("platform_revenue", None, -Decimal(str(order.platform_fee))),
                ],
            )
        order.status = OrderStatus.DIBATALKAN
        sibling = await db.scalar(select(Order.id).where(
            Order.checkout_group_id == order.checkout_group_id,
            Order.id != order.id,
            Order.status != OrderStatus.DIBATALKAN,
        ).limit(1))
        if payment and payment.status in {PaymentStatus.REFUND_PENDING, PaymentStatus.REFUND_FAILED}:
            payment.status = PaymentStatus.BERHASIL if sibling else PaymentStatus.REFUNDED
        await audit(db, action="order.cancelled", entity_type="order", entity_id=order.id, actor_id=buyer.id)
        await db.commit()
        return await self._order_response(db, order.id)

    async def restore_order_inventory(self, db: AsyncSession, order_id: uuid.UUID) -> None:
        """Reverse committed quantities exactly once for a paid order refund."""
        items = await db.execute(select(OrderItem).where(OrderItem.order_id == order_id))
        for item in items.scalars():
            product = await db.get(Product, item.product_id, with_for_update=True)
            quantity = Decimal(str(item.quantity))
            remaining = quantity
            allocations = await db.execute(
                select(ProductStockAllocation)
                .where(ProductStockAllocation.product_id == item.product_id)
                .order_by(ProductStockAllocation.created_at.desc(), ProductStockAllocation.id.desc())
                .with_for_update()
            )
            for allocation in allocations.scalars():
                take = min(Decimal(str(allocation.consumed_quantity)), remaining)
                if take <= 0:
                    continue
                stock = await db.get(Stock, allocation.stock_id, with_for_update=True)
                allocation.consumed_quantity = Decimal(str(allocation.consumed_quantity)) - take
                stock.quantity_available = Decimal(str(stock.quantity_available)) + take
                stock.quantity_reserved = Decimal(str(stock.quantity_reserved)) + take
                stock.status = StockStatus.ACTIVE
                remaining -= take
                if remaining <= 0:
                    break
            if remaining > 0:
                raise ValueError("Allocation stok tidak konsisten; refund dihentikan.")
            product.stock_remaining = Decimal(str(product.stock_remaining)) + quantity
            product.status = ProductStatus.AKTIF

    async def mark_shipped(self, db: AsyncSession, *, order_id: uuid.UUID, distributor: User) -> OrderResponse:
        result = await db.execute(select(Order).where(Order.id == order_id).options(selectinload(Order.shipment)).with_for_update())
        order = result.scalar_one_or_none()
        if not order or order.distributor_id != distributor.id:
            raise PermissionError("Akses pesanan ditolak.")
        if order.status != OrderStatus.DIPROSES:
            raise ValueError("Pesanan harus diproses dan sudah dibayar.")
        shipment = order.shipment
        if shipment.status == ShipmentStatus.PENDING:
            booking = await shipping_provider().book({"order_id": str(order.id), "rate_id": shipment.rate_id})
            shipment.provider_order_id = booking["provider_order_id"]
            shipment.awb = booking["awb"]
            shipment.status = ShipmentStatus.BOOKED
        if not shipment.awb:
            raise ValueError("Nomor tracking belum tersedia.")
        order.status = OrderStatus.DIKIRIM
        await notify(db, user_id=order.buyer_id, kind="shipment", title="Pesanan dikirim", body=f"Nomor resi: {shipment.awb}")
        await db.commit()
        return await self._order_response(db, order.id)

    async def mark_done(self, db: AsyncSession, *, order_id: uuid.UUID, distributor: User) -> OrderResponse:
        order = await db.get(Order, order_id, with_for_update=True)
        if not order or order.distributor_id != distributor.id:
            raise PermissionError("Akses pesanan ditolak.")
        if order.status != OrderStatus.DIKIRIM:
            raise ValueError("Pesanan harus berstatus dikirim.")
        order.status = OrderStatus.SELESAI
        await db.commit()
        return await self._order_response(db, order.id)

    async def _order_response(self, db: AsyncSession, order_id: uuid.UUID) -> OrderResponse:
        result = await db.execute(select(Order).where(Order.id == order_id).options(
            selectinload(Order.items), selectinload(Order.shipping_address), selectinload(Order.payment), selectinload(Order.distributor)
        ))
        order = result.scalar_one()
        response = OrderResponse.model_validate(order)
        if order.items:
            response.product_name = order.items[0].product_name
            response.product_photo = order.items[0].product_photo
        response.distributor_name = order.distributor.full_name if order.distributor else None
        return response


order_service = OrderService()
