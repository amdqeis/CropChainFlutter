# Import all models so Alembic can detect them via Base.metadata

from app.core.database import Base  # noqa: F401

from app.models.user import User, ActiveRole  # noqa: F401
from app.models.role_verification import RoleVerification, RoleType, VerificationStatus  # noqa: F401
from app.models.offer import Offer, OfferStatus, OfferUnit  # noqa: F401
from app.models.stock import Stock, StockStatus  # noqa: F401
from app.models.product import Product, ProductStatus  # noqa: F401
from app.models.address import Address  # noqa: F401
from app.models.cart import Cart, CartItem  # noqa: F401
from app.models.order import Order, OrderStatus, PurchaseMode  # noqa: F401
from app.models.payment import Payment, PaymentStatus, PaymentPurpose  # noqa: F401
from app.models.review import Review  # noqa: F401
from app.models.platform import RefreshSession, AuditLog  # noqa: F401
from app.models.commerce import (  # noqa: F401
    CheckoutGroup, CheckoutStatus, OrderItem, ProductStockAllocation,
    InventoryReservation, ReservationStatus, PaymentAttempt, AttemptStatus,
)
from app.models.operations import (  # noqa: F401
    Shipment, ShipmentEvent, ShipmentStatus, LedgerTransaction, LedgerEntry,
    Payout, PayoutStatus, DeviceToken, Notification, Dispute, DisputeComment,
    DisputeStatus,
)
from app.models.pricing import (  # noqa: F401
    MarketPriceObservation, ModelVersion, TrainingRun, TrainingStatus, PricePrediction,
)
