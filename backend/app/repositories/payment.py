"""
Payment repository.
"""
import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.payment import Payment, PaymentStatus


class PaymentRepository:

    async def create(self, db: AsyncSession, *, payment: Payment) -> Payment:
        db.add(payment)
        await db.commit()
        await db.refresh(payment)
        return payment

    async def get_by_order_id(
        self, db: AsyncSession, *, order_id: uuid.UUID
    ) -> Optional[Payment]:
        result = await db.execute(
            select(Payment).where(Payment.order_id == order_id)
        )
        return result.scalar_one_or_none()

    async def get_by_midtrans_order_id(
        self, db: AsyncSession, *, midtrans_order_id: str
    ) -> Optional[Payment]:
        """Used by webhook handler to find payment by Midtrans order_id."""
        result = await db.execute(
            select(Payment).where(Payment.midtrans_order_id == midtrans_order_id)
        )
        return result.scalar_one_or_none()

    async def update_status(
        self,
        db: AsyncSession,
        *,
        payment: Payment,
        status: PaymentStatus,
        midtrans_transaction_id: Optional[str] = None,
        method: Optional[str] = None,
    ) -> Payment:
        payment.status = status
        if midtrans_transaction_id:
            payment.midtrans_transaction_id = midtrans_transaction_id
        if method:
            payment.method = method
        if status == PaymentStatus.BERHASIL:
            payment.paid_at = datetime.now(timezone.utc)
        await db.commit()
        await db.refresh(payment)
        return payment

    async def update_snap_token(
        self,
        db: AsyncSession,
        *,
        payment: Payment,
        snap_token: str,
        snap_redirect_url: str,
    ) -> Payment:
        payment.snap_token = snap_token
        payment.snap_redirect_url = snap_redirect_url
        await db.commit()
        await db.refresh(payment)
        return payment


payment_repository = PaymentRepository()
