"""Commerce models added after the original MVP schema."""
import enum
import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import DateTime, Enum, ForeignKey, Numeric, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class CheckoutStatus(str, enum.Enum):
    PENDING = "pending"
    PAID = "paid"
    FAILED = "failed"
    CANCELLED = "cancelled"


class ReservationStatus(str, enum.Enum):
    ACTIVE = "active"
    COMMITTED = "committed"
    RELEASED = "released"


class AttemptStatus(str, enum.Enum):
    PENDING = "pending"
    SUCCESS = "success"
    FAILED = "failed"
    REFUNDED = "refunded"


class CheckoutGroup(Base, TimestampMixin):
    __tablename__ = "checkout_groups"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    buyer_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), index=True)
    idempotency_key: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    status: Mapped[CheckoutStatus] = mapped_column(Enum(CheckoutStatus, name="checkout_status_enum", values_callable=enum_values), default=CheckoutStatus.PENDING, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    orders: Mapped[list["Order"]] = relationship("Order", foreign_keys="Order.checkout_group_id")


class OrderItem(Base, TimestampMixin):
    __tablename__ = "order_items"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("orders.id", ondelete="CASCADE"), index=True)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("products.id", ondelete="RESTRICT"), index=True)
    product_name: Mapped[str] = mapped_column(String(255), nullable=False)
    product_photo: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)
    quantity: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    unit_price: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    subtotal: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    purchase_mode: Mapped[str] = mapped_column(String(20), nullable=False)
    order: Mapped["Order"] = relationship("Order", back_populates="items")


class ProductStockAllocation(Base, TimestampMixin):
    __tablename__ = "product_stock_allocations"
    __table_args__ = (UniqueConstraint("product_id", "stock_id", name="uq_product_stock_allocation"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), index=True)
    stock_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("stock.id", ondelete="RESTRICT"), index=True)
    allocated_quantity: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    consumed_quantity: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    product: Mapped["Product"] = relationship("Product", back_populates="allocations")
    stock: Mapped["Stock"] = relationship("Stock")


class InventoryReservation(Base, TimestampMixin):
    __tablename__ = "inventory_reservations"
    __table_args__ = (UniqueConstraint("checkout_group_id", "product_id", name="uq_reservation_checkout_product"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    checkout_group_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("checkout_groups.id", ondelete="CASCADE"), index=True)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), index=True)
    quantity: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    status: Mapped[ReservationStatus] = mapped_column(Enum(ReservationStatus, name="reservation_status_enum", values_callable=enum_values), default=ReservationStatus.ACTIVE, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class PaymentAttempt(Base, TimestampMixin):
    __tablename__ = "payment_attempts"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    payment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("payments.id", ondelete="CASCADE"), index=True)
    external_order_id: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    external_transaction_id: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True)
    idempotency_key: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    status: Mapped[AttemptStatus] = mapped_column(Enum(AttemptStatus, name="attempt_status_enum", values_callable=enum_values), default=AttemptStatus.PENDING, index=True)
    snap_token: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    redirect_url: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)
    provider_payload: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    payment: Mapped["Payment"] = relationship("Payment", back_populates="attempts")
