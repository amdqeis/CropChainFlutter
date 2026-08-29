"""
Offer Pydantic schemas.
"""
import uuid
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.models.offer import OfferStatus, OfferUnit


class OfferCreate(BaseModel):
    """Schema for petani creating a new harvest offer."""
    category: str = Field(..., min_length=2, max_length=100)
    quantity: float = Field(..., gt=0, description="Jumlah hasil panen")
    unit: OfferUnit
    proposed_price: float = Field(..., gt=0, description="Harga yang diinginkan per unit")
    location: str = Field(..., min_length=5, max_length=500)
    photo: List[str] = Field(..., min_length=1, description="Min 1 foto URL diperlukan")
    notes: Optional[str] = Field(None, max_length=2000)

    @field_validator("photo")
    @classmethod
    def validate_photo_count(cls, v: List[str]) -> List[str]:
        if len(v) < 1:
            raise ValueError("Minimal 1 foto diperlukan")
        if len(v) > 5:
            raise ValueError("Maksimal 5 foto diperbolehkan")
        return v


class OfferNegotiate(BaseModel):
    """Schema for distributor negotiating a price on an offer."""
    negotiated_price: float = Field(..., gt=0, description="Harga nego dari distributor")


class OfferResponse(BaseModel):
    """Full offer response including petani info."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    petani_id: uuid.UUID
    distributor_id: Optional[uuid.UUID] = None
    category: str
    quantity: float
    quantity_kg: float
    unit: OfferUnit
    proposed_price: float
    location: str
    photo: List[str]
    notes: Optional[str] = None
    negotiated_price: Optional[float] = None
    status: OfferStatus
    created_at: datetime
    updated_at: datetime

    # Nested petani info (optional, populated when needed)
    petani_name: Optional[str] = None
    petani_location: Optional[str] = None
