"""
Product model — Marketplace listing created by Distributor from their Stock.
Visible to buyers in the marketplace when status = 'aktif'.
"""
import enum
import uuid
from typing import List, Optional

from sqlalchemy import Boolean, Enum, ForeignKey, Numeric, String
from sqlalchemy.dialects.postgresql import ARRAY, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class ProductStatus(str, enum.Enum):
    AKTIF = "aktif"
    NONAKTIF = "nonaktif"


class Product(Base, TimestampMixin):
    __tablename__ = "products"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    distributor_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    stock_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("stock.id", ondelete="RESTRICT"),
        nullable=True,
    )

    # Product Info
    name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    category: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    description: Mapped[Optional[str]] = mapped_column(String(2000), nullable=True)

    # Pricing
    public_price: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    wholesale_price: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)

    # Location & Media
    location: Mapped[str] = mapped_column(String(500), nullable=False)
    photo: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=False, default=list)

    # Traceability toggle
    show_farmer_info: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    # Inventory
    stock_remaining: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    stock_reserved: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    unit: Mapped[str] = mapped_column(String(10), nullable=False, default="kg")

    # Status
    status: Mapped[ProductStatus] = mapped_column(
        Enum(ProductStatus, name="product_status_enum", values_callable=enum_values),
        nullable=False,
        default=ProductStatus.AKTIF,
        index=True,
    )

    # Relationships
    distributor: Mapped["User"] = relationship(
        "User", back_populates="products", foreign_keys=[distributor_id]
    )
    stock: Mapped["Stock"] = relationship("Stock", back_populates="products")
    cart_items: Mapped[List["CartItem"]] = relationship(
        "CartItem", back_populates="product"
    )
    orders: Mapped[List["Order"]] = relationship(
        "Order", back_populates="product", foreign_keys="Order.product_id"
    )
    reviews: Mapped[List["Review"]] = relationship(
        "Review", back_populates="product", foreign_keys="Review.product_id"
    )
    allocations: Mapped[List["ProductStockAllocation"]] = relationship(
        "ProductStockAllocation", back_populates="product", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Product id={self.id} name={self.name} status={self.status}>"
