"""
Address Pydantic schemas.
"""
import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class AddressCreate(BaseModel):
    """Schema for creating a new saved address."""
    label: str = Field(..., min_length=2, max_length=100, description="e.g., 'Rumah', 'Kantor'")
    recipient_name: str = Field(..., min_length=2, max_length=255)
    phone: str = Field(..., min_length=8, max_length=20)
    full_address: str = Field(..., min_length=10, max_length=1000)
    postal_code: str | None = Field(None, min_length=5, max_length=10)
    district: str | None = Field(None, max_length=150)
    city: str | None = Field(None, max_length=150)
    province: str | None = Field(None, max_length=150)
    latitude: float | None = Field(None, ge=-90, le=90)
    longitude: float | None = Field(None, ge=-180, le=180)
    is_default: bool = False


class AddressUpdate(BaseModel):
    """Schema for updating an existing address."""
    label: str | None = Field(None, min_length=2, max_length=100)
    recipient_name: str | None = Field(None, min_length=2, max_length=255)
    phone: str | None = Field(None, min_length=8, max_length=20)
    full_address: str | None = Field(None, min_length=10, max_length=1000)
    postal_code: str | None = Field(None, min_length=5, max_length=10)
    district: str | None = Field(None, max_length=150)
    city: str | None = Field(None, max_length=150)
    province: str | None = Field(None, max_length=150)
    latitude: float | None = Field(None, ge=-90, le=90)
    longitude: float | None = Field(None, ge=-180, le=180)
    is_default: bool | None = None


class AddressResponse(BaseModel):
    """Full address response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    label: str
    recipient_name: str
    phone: str
    full_address: str
    postal_code: str | None = None
    district: str | None = None
    city: str | None = None
    province: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    is_default: bool
    created_at: datetime
    updated_at: datetime
