"""
Review model — Buyer's rating and comment for a completed order.
One review per order (enforced by unique constraint on order_id).
"""
import uuid
from typing import Optional

from sqlalchemy import ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin


class Review(Base, TimestampMixin):
    __tablename__ = "reviews"
    __table_args__ = (
        # Prevent duplicate review for the same order
        UniqueConstraint("order_id", name="uq_reviews_order_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    order_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("orders.id", ondelete="CASCADE"),
        nullable=False,
    )
    buyer_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    product_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("products.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Review Content
    rating: Mapped[int] = mapped_column(Integer, nullable=False)  # 1-5
    comment: Mapped[Optional[str]] = mapped_column(String(2000), nullable=True)

    # Relationships
    order: Mapped["Order"] = relationship("Order", back_populates="review")
    buyer: Mapped["User"] = relationship(
        "User", back_populates="reviews", foreign_keys=[buyer_id]
    )
    product: Mapped["Product"] = relationship(
        "Product", back_populates="reviews", foreign_keys=[product_id]
    )

    def __repr__(self) -> str:
        return f"<Review id={self.id} rating={self.rating} product_id={self.product_id}>"
