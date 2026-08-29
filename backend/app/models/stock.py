"""
Stock model — Auto-created when an Offer is accepted (status → 'diterima').
Represents the distributor's inventory sourced from a petani's offer.
"""
import enum
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Numeric, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import enum_values


class StockStatus(str, enum.Enum):
    PENDING_PAYMENT = "pending_payment"
    ACTIVE = "active"
    DEPLETED = "depleted"


class Stock(Base):
    __tablename__ = "stock"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    distributor_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    offer_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("offers.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,   # One stock record per accepted offer
    )

    # Snapshot from the offer at time of acceptance
    category: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    quantity_available: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    quantity_reserved: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    unit: Mapped[str] = mapped_column(String(10), nullable=False, default="kg")
    status: Mapped[StockStatus] = mapped_column(
        Enum(StockStatus, name="stock_status_enum", values_callable=enum_values), nullable=False,
        default=StockStatus.PENDING_PAYMENT, index=True
    )
    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )

    # Relationships
    distributor: Mapped["User"] = relationship(
        "User", back_populates="stocks", foreign_keys=[distributor_id]
    )
    offer: Mapped["Offer"] = relationship("Offer", back_populates="stock")
    products: Mapped[list["Product"]] = relationship(
        "Product", back_populates="stock"
    )

    def __repr__(self) -> str:
        return (
            f"<Stock id={self.id} category={self.category} "
            f"qty={self.quantity_available}>"
        )
