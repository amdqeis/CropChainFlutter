from fastapi import APIRouter

from app.api.v1 import (
    auth,
    profile,
    offers,
    stock,
    products,
    addresses,
    cart,
    orders,
    payments,
    reviews,
    uploads,
    admin,
    shipping,
    notifications,
    disputes,
    dashboards,
    prices,
)

api_router = APIRouter()

# ─── Auth & Profile ───────────────────────────────────────────────────────────
api_router.include_router(auth.router, prefix="/auth", tags=["🔐 Autentikasi"])
api_router.include_router(profile.router, prefix="/profile", tags=["👤 Profil & Verifikasi"])
api_router.include_router(admin.router, prefix="/admin", tags=["🛡️ Admin"])

# ─── Petani / Distributor — Offer Flow ───────────────────────────────────────
api_router.include_router(offers.router, prefix="/offers", tags=["🌾 Tawaran (Petani ↔ Distributor)"])
api_router.include_router(stock.router, prefix="/stock", tags=["📦 Stok Distributor"])

# ─── Marketplace ─────────────────────────────────────────────────────────────
api_router.include_router(products.router, prefix="/products", tags=["🛒 Produk & Marketplace"])

# ─── Pembeli — Purchase Flow ──────────────────────────────────────────────────
api_router.include_router(addresses.router, prefix="/addresses", tags=["📍 Alamat Pengiriman"])
api_router.include_router(cart.router, prefix="/cart", tags=["🛍️ Keranjang Belanja"])
api_router.include_router(orders.router, prefix="/orders", tags=["📋 Pesanan"])
api_router.include_router(payments.router, prefix="/payments", tags=["💳 Pembayaran (Midtrans)"])
api_router.include_router(shipping.router, prefix="/shipping", tags=["🚚 Pengiriman"])
api_router.include_router(shipping.shipment_router, prefix="/shipments", tags=["🚚 Shipment"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["🔔 Notifikasi"])
api_router.include_router(notifications.device_router, prefix="/devices", tags=["📱 Device"])
api_router.include_router(disputes.router, prefix="/disputes", tags=["⚖️ Dispute"])
api_router.include_router(disputes.admin_router, prefix="/admin/disputes", tags=["🛡️ Admin Dispute"])
api_router.include_router(dashboards.router, prefix="/dashboards", tags=["📊 Dashboard & Ledger"])
api_router.include_router(dashboards.finance_router, tags=["💰 Ledger & Payout"])
api_router.include_router(prices.router, prefix="/prices", tags=["📈 Prediksi Harga"])
api_router.include_router(prices.admin_router, prefix="/admin/ml", tags=["🧠 Admin ML"])
api_router.include_router(reviews.router, prefix="/reviews", tags=["⭐ Ulasan Produk"])

# ─── Utilities ────────────────────────────────────────────────────────────────
api_router.include_router(uploads.router, prefix="/uploads", tags=["📷 Upload File"])
