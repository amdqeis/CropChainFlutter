"""
Cart Pydantic schemas.
"""
import uuid
from typing import List

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.product import ProductResponse


class CartItemAdd(BaseModel):
    """Schema for adding a product to cart."""
    product_id: uuid.UUID
    quantity: float = Field(..., gt=0)


class CartItemUpdate(BaseModel):
    """Schema for updating quantity of a cart item."""
    quantity: float = Field(..., gt=0)


class CartItemResponse(BaseModel):
    """Single cart item response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    cart_id: uuid.UUID
    product_id: uuid.UUID
    quantity: float

    # Enriched
    product: ProductResponse | None = None


class CartResponse(BaseModel):
    """Full cart response with items and total."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    items: List[CartItemResponse] = []

    # Computed
    total_items: int = 0
    subtotal: float = 0.0
