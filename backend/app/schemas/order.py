"""Order and checkout schemas."""
import uuid
from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.models.order import OrderStatus, PurchaseMode
from app.schemas.address import AddressResponse
from app.schemas.payment import PaymentResponse


class CheckoutItem(BaseModel):
    product_id: uuid.UUID
    quantity: float = Field(..., gt=0)
    purchase_mode: PurchaseMode = PurchaseMode.RETAIL


class CheckoutRequest(BaseModel):
    source: Literal["buy_now", "cart"] = "buy_now"
    items: list[CheckoutItem] = Field(default_factory=list)
    cart_item_ids: list[uuid.UUID] = Field(default_factory=list)
    shipping_address_id: uuid.UUID
    payment_method: str = Field(..., min_length=2, max_length=100)
    shipping_rate_ids: dict[str, str] = Field(default_factory=dict)
    idempotency_key: str = Field(..., min_length=8, max_length=255)
    # Backward-compatible single-product fields.
    product_id: Optional[uuid.UUID] = None
    quantity: Optional[float] = Field(None, gt=0)
    purchase_mode: Optional[PurchaseMode] = None

    @model_validator(mode="after")
    def normalize_legacy(self):
        if self.product_id and not self.items:
            self.items = [CheckoutItem(product_id=self.product_id, quantity=self.quantity or 1, purchase_mode=self.purchase_mode or PurchaseMode.RETAIL)]
        if self.source == "buy_now" and not self.items:
            raise ValueError("items wajib diisi untuk buy_now")
        if self.source == "cart" and not self.cart_item_ids:
            raise ValueError("cart_item_ids wajib diisi untuk cart")
        product_ids = [item.product_id for item in self.items]
        if len(product_ids) != len(set(product_ids)):
            raise ValueError("Produk yang sama tidak boleh muncul lebih dari sekali dalam checkout")
        if len(self.cart_item_ids) != len(set(self.cart_item_ids)):
            raise ValueError("cart_item_ids tidak boleh duplikat")
        return self


class OrderItemResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    product_id: uuid.UUID
    product_name: str
    product_photo: Optional[str] = None
    quantity: float
    unit_price: float
    subtotal: float
    purchase_mode: str


class OrderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    checkout_group_id: Optional[uuid.UUID] = None
    buyer_id: uuid.UUID
    distributor_id: uuid.UUID
    product_id: uuid.UUID
    shipping_address_id: uuid.UUID
    quantity: float
    purchase_mode: PurchaseMode
    payment_method: str
    total_price: float
    shipping_fee: float
    platform_fee: float
    status: OrderStatus
    created_at: datetime
    updated_at: datetime
    shipping_address: Optional[AddressResponse] = None
    payment: Optional[PaymentResponse] = None
    items: list[OrderItemResponse] = Field(default_factory=list)
    product_name: Optional[str] = None
    product_photo: Optional[str] = None
    distributor_name: Optional[str] = None


class CheckoutResponse(BaseModel):
    checkout_group_id: uuid.UUID
    orders: list[OrderResponse]
    payment: PaymentResponse
    expires_at: datetime
