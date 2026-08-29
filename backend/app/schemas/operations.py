import uuid
from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field

from app.models.operations import DisputeStatus, ShipmentStatus


class LocationSearchResponse(BaseModel):
    id: str
    label: str
    postal_code: Optional[str] = None


class ShippingRateRequest(BaseModel):
    origin: dict
    destination: dict
    weight_kg: float = Field(..., gt=0)


class ShipmentEventResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    status: ShipmentStatus
    description: str
    location: Optional[str] = None
    occurred_at: datetime


class ShipmentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    order_id: uuid.UUID
    provider: str
    provider_order_id: Optional[str] = None
    rate_id: str
    courier: str
    service: str
    fee: float
    awb: Optional[str] = None
    status: ShipmentStatus
    eta: Optional[datetime] = None
    events: list[ShipmentEventResponse] = Field(default_factory=list)


class DeviceTokenCreate(BaseModel):
    token: str = Field(..., min_length=10, max_length=1000)
    platform: str = Field(..., pattern="^(android|ios|web)$")


class NotificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    kind: str
    title: str
    body: str
    payload: dict
    read_at: Optional[datetime] = None
    created_at: datetime


class DisputeCreate(BaseModel):
    order_id: uuid.UUID
    category: str = Field(..., min_length=2, max_length=100)
    description: str = Field(..., min_length=10, max_length=5000)
    evidence: list[str] = Field(default_factory=list, max_length=5)


class DisputeResolve(BaseModel):
    status: DisputeStatus
    resolution: str = Field(..., min_length=5, max_length=5000)
    refund_approved: bool = False


class DisputeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    order_id: uuid.UUID
    opened_by_id: uuid.UUID
    assigned_admin_id: Optional[uuid.UUID] = None
    category: str
    description: str
    evidence: list[str]
    status: DisputeStatus
    resolution: Optional[str] = None
    refund_approved: bool
    created_at: datetime
    updated_at: datetime


class PriceObservationInput(BaseModel):
    observed_at: date
    commodity: str
    district: str
    price_per_kg: float = Field(..., gt=0)
    source: str
    volume_kg: Optional[float] = Field(None, gt=0)
    is_synthetic: bool = False


class PricePredictionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    commodity: str
    district: str
    horizon_days: int
    predicted_for: date
    predicted_price_per_kg: float
    lower_bound: float
    upper_bound: float
    model_version: str
    is_baseline: bool
