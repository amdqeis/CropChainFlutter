"""
Review Pydantic schemas.
"""
import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ReviewCreate(BaseModel):
    """Schema for buyer creating a product review."""
    order_id: uuid.UUID
    rating: int = Field(..., ge=1, le=5, description="Rating 1-5")
    comment: Optional[str] = Field(None, max_length=2000)


class ReviewResponse(BaseModel):
    """Full review response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    order_id: uuid.UUID
    buyer_id: uuid.UUID
    product_id: uuid.UUID
    rating: int
    comment: Optional[str] = None
    created_at: datetime

    # Enriched
    buyer_name: Optional[str] = None
