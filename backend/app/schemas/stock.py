"""
Stock Pydantic schemas.
"""
import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict
from app.models.stock import StockStatus


class StockResponse(BaseModel):
    """Stock item response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    distributor_id: uuid.UUID
    offer_id: uuid.UUID
    category: str
    quantity_available: float
    quantity_reserved: float
    unit: str
    status: StockStatus
    received_at: datetime


class StockAggregateResponse(BaseModel):
    """Aggregated stock summary per category for distributor dashboard."""
    category: str
    total_quantity_available: float
    stock_count: int  # Number of individual stock records in this category
