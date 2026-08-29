"""
Payment Pydantic schemas.
"""
import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

from app.models.payment import PaymentStatus


class PaymentResponse(BaseModel):
    """Payment status response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    order_id: Optional[uuid.UUID] = None
    offer_id: Optional[uuid.UUID] = None
    checkout_group_id: Optional[uuid.UUID] = None
    payer_id: uuid.UUID
    payee_id: Optional[uuid.UUID] = None
    purpose: str
    midtrans_transaction_id: Optional[str] = None
    midtrans_order_id: str
    method: Optional[str] = None
    snap_token: Optional[str] = None
    snap_redirect_url: Optional[str] = None
    amount: float
    status: PaymentStatus
    paid_at: Optional[datetime] = None
    created_at: datetime


class PaymentAttemptResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    external_order_id: str
    status: str
    snap_token: Optional[str] = None
    redirect_url: Optional[str] = None
    created_at: datetime


class MidtransWebhookPayload(BaseModel):
    """
    Schema for Midtrans payment notification webhook payload.
    Only the fields we actually use are typed strictly; the rest are optional.
    """
    transaction_status: str
    order_id: str
    transaction_id: str
    gross_amount: str
    payment_type: str
    signature_key: str
    fraud_status: Optional[str] = None
    status_code: Optional[str] = None

    model_config = ConfigDict(extra="allow")
