"""
Payment model — Tracks payment transactions via Midtrans.

Status flow:
  menunggu → berhasil  (Midtrans webhook settlement)
  menunggu → gagal     (Midtrans webhook deny/expire/cancel)
  berhasil → refunded  (when Order is cancelled after payment)
"""
import enum
import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import DateTime, Enum, ForeignKey, Numeric, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class PaymentStatus(str, enum.Enum):
    MENUNGGU = "menunggu"
    BERHASIL = "berhasil"
    GAGAL = "gagal"
    REFUNDED = "refunded"
    REFUND_PENDING = "refund_pending"
    REFUND_FAILED = "refund_failed"


class PaymentPurpose(str, enum.Enum):
    BUYER_ORDER = "buyer_order"
    FARMER_OFFER = "farmer_offer"


class Payment(Base, TimestampMixin):
    __tablename__ = "payments"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    order_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("orders.id", ondelete="CASCADE"),
        nullable=True,
        unique=True,
    )
    offer_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("offers.id", ondelete="CASCADE"), nullable=True, unique=True
    )
    checkout_group_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("checkout_groups.id", ondelete="SET NULL"), nullable=True, index=True
    )
    payer_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    payee_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    purpose: Mapped[PaymentPurpose] = mapped_column(
        Enum(PaymentPurpose, name="payment_purpose_enum", values_callable=enum_values), nullable=False
    )
    idempotency_key: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)

    # Midtrans data
    midtrans_transaction_id: Mapped[Optional[str]] = mapped_column(
        String(255), nullable=True, unique=True
    )
    midtrans_order_id: Mapped[str] = mapped_column(
        String(255), nullable=False, unique=True
    )
    method: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    snap_token: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    snap_redirect_url: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)

    # Amount & Status
    amount: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    status: Mapped[PaymentStatus] = mapped_column(
        Enum(PaymentStatus, name="payment_status_enum", values_callable=enum_values),
        nullable=False,
        default=PaymentStatus.MENUNGGU,
    )
    paid_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Relationships
    order: Mapped[Optional["Order"]] = relationship("Order", back_populates="payment")
    attempts: Mapped[list["PaymentAttempt"]] = relationship(
        "PaymentAttempt", back_populates="payment", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Payment id={self.id} status={self.status} amount={self.amount}>"
