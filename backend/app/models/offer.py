"""
Offer model — Petani's harvest offer to Distributor.

Status flow:
  menunggu → (distributor nego) → setuju_harga_baru → (petani terima) → diterima → selesai
  menunggu | setuju_harga_baru → (ditolak) → tolak
"""
import enum
import uuid
from typing import List, Optional

from sqlalchemy import Enum, ForeignKey, Numeric, String, Text
from sqlalchemy.dialects.postgresql import ARRAY, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class OfferUnit(str, enum.Enum):
    KG = "kg"
    TON = "ton"


class OfferStatus(str, enum.Enum):
    MENUNGGU = "menunggu"
    SETUJU_HARGA_BARU = "setuju_harga_baru"
    DITERIMA = "diterima"
    TOLAK = "tolak"
    SELESAI = "selesai"


class Offer(Base, TimestampMixin):
    __tablename__ = "offers"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    petani_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    distributor_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True
    )

    # Offer Details
    category: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    quantity: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    quantity_kg: Mapped[float] = mapped_column(Numeric(14, 2), nullable=False)
    unit: Mapped[OfferUnit] = mapped_column(
        Enum(OfferUnit, name="offer_unit_enum", values_callable=enum_values), nullable=False
    )
    proposed_price: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    location: Mapped[str] = mapped_column(String(500), nullable=False)
    photo: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=False, default=list)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Negotiation — filled by distributor when negotiating
    negotiated_price: Mapped[Optional[float]] = mapped_column(Numeric(15, 2), nullable=True)

    # Status
    status: Mapped[OfferStatus] = mapped_column(
        Enum(OfferStatus, name="offer_status_enum", values_callable=enum_values),
        nullable=False,
        default=OfferStatus.MENUNGGU,
        index=True,
    )

    # Relationships
    petani: Mapped["User"] = relationship(
        "User", back_populates="offers", foreign_keys=[petani_id]
    )
    distributor: Mapped[Optional["User"]] = relationship(
        "User", foreign_keys=[distributor_id]
    )
    stock: Mapped[Optional["Stock"]] = relationship(
        "Stock", back_populates="offer", uselist=False
    )

    def __repr__(self) -> str:
        return f"<Offer id={self.id} category={self.category} status={self.status}>"
