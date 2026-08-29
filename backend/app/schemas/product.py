"""
Product Pydantic schemas.
"""
import uuid
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.models.product import ProductStatus
from app.schemas.review import ReviewResponse


class StockAllocationInput(BaseModel):
    stock_id: uuid.UUID
    quantity: float = Field(..., gt=0)


class ProductCreate(BaseModel):
    """Schema for distributor creating a new product listing."""
    stock_id: Optional[uuid.UUID] = None
    allocations: Optional[List[StockAllocationInput]] = None
    name: str = Field(..., min_length=2, max_length=255)
    category: str = Field(..., min_length=2, max_length=100)
    description: Optional[str] = Field(None, max_length=2000)
    public_price: float = Field(..., gt=0, description="Harga jual retail (per unit)")
    wholesale_price: float = Field(..., gt=0, description="Harga jual grosir (per unit)")
    location: str = Field(..., min_length=5, max_length=500)
    photo: List[str] = Field(..., min_length=1)
    show_farmer_info: bool = Field(False, description="Tampilkan info petani asal ke pembeli")
    stock_remaining: float = Field(..., gt=0)

    @model_validator(mode="after")
    def validate_allocations(self):
        if not self.allocations and not self.stock_id:
            raise ValueError("stock_id atau allocations wajib diisi")
        if self.allocations:
            total = sum(item.quantity for item in self.allocations)
            if abs(total - self.stock_remaining) > 0.001:
                raise ValueError("Total allocations harus sama dengan stock_remaining")
        return self

    @field_validator("photo")
    @classmethod
    def validate_photo_count(cls, v: List[str]) -> List[str]:
        if len(v) < 1:
            raise ValueError("Minimal 1 foto diperlukan")
        if len(v) > 5:
            raise ValueError("Maksimal 5 foto diperbolehkan")
        return v


class ProductUpdate(BaseModel):
    """Schema for updating an existing product."""
    name: Optional[str] = Field(None, min_length=2, max_length=255)
    category: Optional[str] = Field(None, max_length=100)
    description: Optional[str] = Field(None, max_length=2000)
    public_price: Optional[float] = Field(None, gt=0)
    wholesale_price: Optional[float] = Field(None, gt=0)
    location: Optional[str] = Field(None, max_length=500)
    photo: Optional[List[str]] = None
    show_farmer_info: Optional[bool] = None
    status: Optional[ProductStatus] = None


class DistributorInfo(BaseModel):
    """Inline distributor info for product detail."""
    id: uuid.UUID
    full_name: str


class FarmerOriginInfo(BaseModel):
    """Inline farmer traceability info — only shown if show_farmer_info=True."""
    petani_id: uuid.UUID
    petani_name: str
    offer_location: str
    category: str


class ProductResponse(BaseModel):
    """Full product response for marketplace."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    distributor_id: uuid.UUID
    stock_id: Optional[uuid.UUID] = None
    name: str
    category: str
    description: Optional[str] = None
    public_price: float
    wholesale_price: float
    location: str
    photo: List[str]
    show_farmer_info: bool
    stock_remaining: float
    stock_reserved: float
    unit: str
    status: ProductStatus
    created_at: datetime
    updated_at: datetime

    # Enriched data (populated by service layer)
    distributor_info: Optional[DistributorInfo] = None
    farmer_origin_info: Optional[FarmerOriginInfo] = None
    farmer_origins: List[FarmerOriginInfo] = Field(default_factory=list)
    average_rating: Optional[float] = None
    review_count: Optional[int] = None
    reviews: Optional[List[ReviewResponse]] = None
