"""Logistics, finance, notifications, and dispute models."""
import enum
import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Index, Numeric, String, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class ShipmentStatus(str, enum.Enum):
    PENDING = "pending"
    BOOKED = "booked"
    PICKED_UP = "picked_up"
    IN_TRANSIT = "in_transit"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"
    FAILED = "failed"


class DisputeStatus(str, enum.Enum):
    OPEN = "open"
    IN_REVIEW = "in_review"
    RESOLVED = "resolved"
    REJECTED = "rejected"


class PayoutStatus(str, enum.Enum):
    PENDING = "pending"
    PAID = "paid"
    FAILED = "failed"


class Shipment(Base, TimestampMixin):
    __tablename__ = "shipments"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("orders.id", ondelete="CASCADE"), unique=True)
    provider: Mapped[str] = mapped_column(String(50), nullable=False, default="fake")
    provider_order_id: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True)
    rate_id: Mapped[str] = mapped_column(String(255), nullable=False)
    courier: Mapped[str] = mapped_column(String(100), nullable=False)
    service: Mapped[str] = mapped_column(String(100), nullable=False)
    fee: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    awb: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True)
    status: Mapped[ShipmentStatus] = mapped_column(Enum(ShipmentStatus, name="shipment_status_enum", values_callable=enum_values), default=ShipmentStatus.PENDING, index=True)
    eta: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    provider_payload: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    order: Mapped["Order"] = relationship("Order", back_populates="shipment")
    events: Mapped[list["ShipmentEvent"]] = relationship("ShipmentEvent", back_populates="shipment", cascade="all, delete-orphan")


class ShipmentEvent(Base):
    __tablename__ = "shipment_events"
    __table_args__ = (UniqueConstraint("shipment_id", "provider_event_id", name="uq_shipment_provider_event"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    shipment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shipments.id", ondelete="CASCADE"), index=True)
    provider_event_id: Mapped[str] = mapped_column(String(255), nullable=False)
    status: Mapped[ShipmentStatus] = mapped_column(Enum(ShipmentStatus, name="shipment_status_enum", values_callable=enum_values, create_type=False), nullable=False)
    description: Mapped[str] = mapped_column(String(1000), nullable=False)
    location: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    shipment: Mapped[Shipment] = relationship("Shipment", back_populates="events")


class LedgerTransaction(Base):
    __tablename__ = "ledger_transactions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    reference_type: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    reference_id: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    description: Mapped[str] = mapped_column(String(500), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    entries: Mapped[list["LedgerEntry"]] = relationship("LedgerEntry", cascade="all, delete-orphan")


class LedgerEntry(Base):
    __tablename__ = "ledger_entries"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    transaction_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("ledger_transactions.id", ondelete="CASCADE"), index=True)
    account_code: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), index=True)
    amount: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)


class Payout(Base, TimestampMixin):
    __tablename__ = "payouts"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), index=True)
    payment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("payments.id"), unique=True)
    amount: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    status: Mapped[PayoutStatus] = mapped_column(Enum(PayoutStatus, name="payout_status_enum", values_callable=enum_values), default=PayoutStatus.PENDING, index=True)
    paid_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)


class DeviceToken(Base, TimestampMixin):
    __tablename__ = "device_tokens"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True)
    token: Mapped[str] = mapped_column(String(1000), unique=True, nullable=False)
    platform: Mapped[str] = mapped_column(String(30), nullable=False)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class Notification(Base, TimestampMixin):
    __tablename__ = "notifications"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True)
    kind: Mapped[str] = mapped_column(String(100), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(String(2000), nullable=False)
    payload: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    read_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    delivered_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    attempts: Mapped[int] = mapped_column(nullable=False, default=0)
    last_error: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)


class Dispute(Base, TimestampMixin):
    __tablename__ = "disputes"
    __table_args__ = (
        Index(
            "uq_active_dispute_per_order",
            "order_id",
            unique=True,
            postgresql_where=text("status IN ('open', 'in_review')"),
        ),
    )
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("orders.id"), index=True)
    opened_by_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), index=True)
    assigned_admin_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    category: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    evidence: Mapped[list[str]] = mapped_column(ARRAY(String), nullable=False, default=list)
    status: Mapped[DisputeStatus] = mapped_column(Enum(DisputeStatus, name="dispute_status_enum", values_callable=enum_values), default=DisputeStatus.OPEN, index=True)
    resolution: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    refund_approved: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)


class DisputeComment(Base, TimestampMixin):
    __tablename__ = "dispute_comments"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    dispute_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("disputes.id", ondelete="CASCADE"), index=True)
    author_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    message: Mapped[str] = mapped_column(Text, nullable=False)
