"""
User model — Single account, multi-role system.
Each user has one account with an active_role that can be switched
after the corresponding role has been verified (except Pembeli which is default).
"""
import enum
import uuid
from typing import List, Optional

from sqlalchemy import Boolean, Enum, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class ActiveRole(str, enum.Enum):
    PEMBELI = "pembeli"
    DISTRIBUTOR = "distributor"
    PETANI = "petani"


class User(Base, TimestampMixin):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)

    # Multi-role system
    active_role: Mapped[ActiveRole] = mapped_column(
        Enum(ActiveRole, name="active_role_enum", values_callable=enum_values),
        nullable=False,
        default=ActiveRole.PEMBELI,
    )

    # Email verification
    is_email_verified: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    is_admin: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, index=True)

    # Relationships
    role_verifications: Mapped[List["RoleVerification"]] = relationship(
        "RoleVerification", back_populates="user", cascade="all, delete-orphan"
    )
    offers: Mapped[List["Offer"]] = relationship(
        "Offer", back_populates="petani", foreign_keys="Offer.petani_id"
    )
    stocks: Mapped[List["Stock"]] = relationship(
        "Stock", back_populates="distributor", foreign_keys="Stock.distributor_id"
    )
    products: Mapped[List["Product"]] = relationship(
        "Product", back_populates="distributor", foreign_keys="Product.distributor_id"
    )
    addresses: Mapped[List["Address"]] = relationship(
        "Address", back_populates="user", cascade="all, delete-orphan"
    )
    cart: Mapped[Optional["Cart"]] = relationship(
        "Cart", back_populates="user", uselist=False, cascade="all, delete-orphan"
    )
    orders_as_buyer: Mapped[List["Order"]] = relationship(
        "Order", back_populates="buyer", foreign_keys="Order.buyer_id"
    )
    orders_as_distributor: Mapped[List["Order"]] = relationship(
        "Order", back_populates="distributor", foreign_keys="Order.distributor_id"
    )
    reviews: Mapped[List["Review"]] = relationship(
        "Review", back_populates="buyer", foreign_keys="Review.buyer_id"
    )

    def __repr__(self) -> str:
        return f"<User email={self.email} active_role={self.active_role}>"
