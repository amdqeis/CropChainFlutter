"""
Order model — Created when buyer completes checkout.

Status flow:
  diproses → dikirim → selesai
  diproses → dibatalkan  (only buyer can cancel while 'diproses')
"""
import enum
import uuid

from sqlalchemy import Enum, ForeignKey, Numeric, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class PurchaseMode(str, enum.Enum):
    RETAIL = "retail"
    GROSIR = "grosir"


class OrderStatus(str, enum.Enum):
    MENUNGGU_PEMBAYARAN = "menunggu_pembayaran"
    DIPROSES = "diproses"
    DIKIRIM = "dikirim"
    SELESAI = "selesai"
    DIBATALKAN = "dibatalkan"


class Order(Base, TimestampMixin):
    __tablename__ = "orders"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    checkout_group_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("checkout_groups.id", ondelete="SET NULL"), nullable=True, index=True
    )

    # Parties
    buyer_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    distributor_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    product_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("products.id", ondelete="RESTRICT"),
        nullable=False,
    )
    shipping_address_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("addresses.id", ondelete="RESTRICT"),
        nullable=False,
    )

    # Order Details
    quantity: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    purchase_mode: Mapped[PurchaseMode] = mapped_column(
        Enum(PurchaseMode, name="purchase_mode_enum", values_callable=enum_values), nullable=False
    )
    payment_method: Mapped[str] = mapped_column(String(100), nullable=False)

    # Pricing Breakdown
    total_price: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    shipping_fee: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False, default=0)
    platform_fee: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False, default=0)

    # Status
    status: Mapped[OrderStatus] = mapped_column(
        Enum(OrderStatus, name="order_status_enum", values_callable=enum_values),
        nullable=False,
        default=OrderStatus.DIPROSES,
        index=True,
    )

    # Relationships
    buyer: Mapped["User"] = relationship(
        "User", back_populates="orders_as_buyer", foreign_keys=[buyer_id]
    )
    distributor: Mapped["User"] = relationship(
        "User", back_populates="orders_as_distributor", foreign_keys=[distributor_id]
    )
    product: Mapped["Product"] = relationship(
        "Product", back_populates="orders", foreign_keys=[product_id]
    )
    shipping_address: Mapped["Address"] = relationship(
        "Address", back_populates="orders"
    )
    payment: Mapped["Payment"] = relationship(
        "Payment", back_populates="order", uselist=False, cascade="all, delete-orphan"
    )
    review: Mapped["Review"] = relationship(
        "Review", back_populates="order", uselist=False, cascade="all, delete-orphan"
    )
    items: Mapped[list["OrderItem"]] = relationship(
        "OrderItem", back_populates="order", cascade="all, delete-orphan"
    )
    shipment: Mapped["Shipment | None"] = relationship(
        "Shipment", back_populates="order", uselist=False, cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Order id={self.id} status={self.status} total={self.total_price}>"
