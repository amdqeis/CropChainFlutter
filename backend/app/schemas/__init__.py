# Centralized schema imports for convenience
from app.schemas.user import (
    UserRegister,
    OTPVerify,
    OTPResend,
    UserLogin,
    PasswordResetRequest,
    PasswordResetConfirm,
    TokenPair,
    TokenRefreshRequest,
    TokenData,
    UserResponse,
    UserUpdate,
    ActiveRoleSwitch,
    VerificationStatusInfo,
)
from app.schemas.role_verification import (
    RoleVerificationCreate,
    RoleVerificationResponse,
    RoleVerificationStatusResponse,
)
from app.schemas.offer import OfferCreate, OfferNegotiate, OfferResponse
from app.schemas.stock import StockResponse, StockAggregateResponse
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse
from app.schemas.address import AddressCreate, AddressUpdate, AddressResponse
from app.schemas.cart import CartItemAdd, CartItemUpdate, CartResponse
from app.schemas.order import CheckoutRequest, OrderResponse
from app.schemas.payment import PaymentResponse, MidtransWebhookPayload
from app.schemas.review import ReviewCreate, ReviewResponse
