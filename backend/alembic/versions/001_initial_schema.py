"""Initial schema — CropChain full database schema.

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-07-13

Tables created:
  - users
  - role_verifications
  - offers
  - stock
  - products
  - addresses
  - carts
  - cart_items
  - orders
  - payments
  - reviews
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "001_initial_schema"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ── Enable uuid-ossp extension ───────────────────────────────────────────
    op.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"')

    # Enum types are created once by the first table that uses each sa.Enum.
    # Creating them manually here as well makes a fresh PostgreSQL install fail
    # with DuplicateObjectError.

    # ── users ─────────────────────────────────────────────────────────────────
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("full_name", sa.String(255), nullable=False),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column("active_role", sa.Enum("pembeli", "distributor", "petani", name="active_role_enum"), nullable=False, server_default="pembeli"),
        sa.Column("is_email_verified", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_users_id", "users", ["id"])
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    # ── role_verifications ────────────────────────────────────────────────────
    op.create_table(
        "role_verifications",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("role_type", sa.Enum("petani", "distributor", name="role_type_enum"), nullable=False),
        sa.Column("ktp_number", sa.String(50), nullable=False),
        sa.Column("ktp_photo", sa.String(500), nullable=False),
        sa.Column("location", sa.String(500), nullable=False),
        sa.Column("status", sa.Enum("pending", "approved", "rejected", name="verification_status_enum"), nullable=False, server_default="pending"),
        sa.Column("rejection_reason", sa.String(1000), nullable=True),
        sa.Column("submitted_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("verified_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_role_verifications_user_id", "role_verifications", ["user_id"])

    # ── offers ────────────────────────────────────────────────────────────────
    op.create_table(
        "offers",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("petani_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("category", sa.String(100), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 2), nullable=False),
        sa.Column("unit", sa.Enum("kg", "ton", name="offer_unit_enum"), nullable=False),
        sa.Column("proposed_price", sa.Numeric(15, 2), nullable=False),
        sa.Column("location", sa.String(500), nullable=False),
        sa.Column("photo", postgresql.ARRAY(sa.String()), nullable=False, server_default="{}"),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("negotiated_price", sa.Numeric(15, 2), nullable=True),
        sa.Column("status", sa.Enum("menunggu", "setuju_harga_baru", "diterima", "tolak", "selesai", name="offer_status_enum"), nullable=False, server_default="menunggu"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_offers_id", "offers", ["id"])
    op.create_index("ix_offers_petani_id", "offers", ["petani_id"])
    op.create_index("ix_offers_category", "offers", ["category"])
    op.create_index("ix_offers_status", "offers", ["status"])

    # ── stock ─────────────────────────────────────────────────────────────────
    op.create_table(
        "stock",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("distributor_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("offer_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("offers.id", ondelete="CASCADE"), nullable=False, unique=True),
        sa.Column("category", sa.String(100), nullable=False),
        sa.Column("quantity_available", sa.Numeric(12, 2), nullable=False),
        sa.Column("received_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_stock_id", "stock", ["id"])
    op.create_index("ix_stock_distributor_id", "stock", ["distributor_id"])
    op.create_index("ix_stock_category", "stock", ["category"])

    # ── products ──────────────────────────────────────────────────────────────
    op.create_table(
        "products",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("distributor_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("stock_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("stock.id", ondelete="RESTRICT"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("category", sa.String(100), nullable=False),
        sa.Column("description", sa.String(2000), nullable=True),
        sa.Column("public_price", sa.Numeric(15, 2), nullable=False),
        sa.Column("wholesale_price", sa.Numeric(15, 2), nullable=False),
        sa.Column("location", sa.String(500), nullable=False),
        sa.Column("photo", postgresql.ARRAY(sa.String()), nullable=False, server_default="{}"),
        sa.Column("show_farmer_info", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("stock_remaining", sa.Numeric(12, 2), nullable=False),
        sa.Column("status", sa.Enum("aktif", "nonaktif", name="product_status_enum"), nullable=False, server_default="aktif"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_products_id", "products", ["id"])
    op.create_index("ix_products_distributor_id", "products", ["distributor_id"])
    op.create_index("ix_products_name", "products", ["name"])
    op.create_index("ix_products_category", "products", ["category"])
    op.create_index("ix_products_status", "products", ["status"])

    # ── addresses ─────────────────────────────────────────────────────────────
    op.create_table(
        "addresses",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("label", sa.String(100), nullable=False),
        sa.Column("recipient_name", sa.String(255), nullable=False),
        sa.Column("phone", sa.String(20), nullable=False),
        sa.Column("full_address", sa.String(1000), nullable=False),
        sa.Column("is_default", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_addresses_id", "addresses", ["id"])
    op.create_index("ix_addresses_user_id", "addresses", ["user_id"])

    # ── carts ─────────────────────────────────────────────────────────────────
    op.create_table(
        "carts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    # ── cart_items ────────────────────────────────────────────────────────────
    op.create_table(
        "cart_items",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("cart_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("carts.id", ondelete="CASCADE"), nullable=False),
        sa.Column("product_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("products.id", ondelete="CASCADE"), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("cart_id", "product_id", name="uq_cart_items_cart_product"),
    )
    op.create_index("ix_cart_items_cart_id", "cart_items", ["cart_id"])

    # ── orders ────────────────────────────────────────────────────────────────
    op.create_table(
        "orders",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("buyer_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="RESTRICT"), nullable=False),
        sa.Column("distributor_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="RESTRICT"), nullable=False),
        sa.Column("product_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("products.id", ondelete="RESTRICT"), nullable=False),
        sa.Column("shipping_address_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("addresses.id", ondelete="RESTRICT"), nullable=False),
        sa.Column("quantity", sa.Numeric(12, 2), nullable=False),
        sa.Column("purchase_mode", sa.Enum("retail", "grosir", name="purchase_mode_enum"), nullable=False),
        sa.Column("payment_method", sa.String(100), nullable=False),
        sa.Column("total_price", sa.Numeric(15, 2), nullable=False),
        sa.Column("shipping_fee", sa.Numeric(15, 2), nullable=False, server_default="0"),
        sa.Column("platform_fee", sa.Numeric(15, 2), nullable=False, server_default="0"),
        sa.Column("status", sa.Enum("diproses", "dikirim", "selesai", "dibatalkan", name="order_status_enum"), nullable=False, server_default="diproses"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_orders_id", "orders", ["id"])
    op.create_index("ix_orders_buyer_id", "orders", ["buyer_id"])
    op.create_index("ix_orders_distributor_id", "orders", ["distributor_id"])
    op.create_index("ix_orders_status", "orders", ["status"])

    # ── payments ──────────────────────────────────────────────────────────────
    op.create_table(
        "payments",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("orders.id", ondelete="CASCADE"), nullable=False, unique=True),
        sa.Column("midtrans_transaction_id", sa.String(255), nullable=True, unique=True),
        sa.Column("midtrans_order_id", sa.String(255), nullable=False, unique=True),
        sa.Column("method", sa.String(100), nullable=True),
        sa.Column("snap_token", sa.String(500), nullable=True),
        sa.Column("snap_redirect_url", sa.String(1000), nullable=True),
        sa.Column("amount", sa.Numeric(15, 2), nullable=False),
        sa.Column("status", sa.Enum("menunggu", "berhasil", "gagal", "refunded", name="payment_status_enum"), nullable=False, server_default="menunggu"),
        sa.Column("paid_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_payments_id", "payments", ["id"])

    # ── reviews ───────────────────────────────────────────────────────────────
    op.create_table(
        "reviews",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text("uuid_generate_v4()")),
        sa.Column("order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("orders.id", ondelete="CASCADE"), nullable=False),
        sa.Column("buyer_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("product_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("products.id", ondelete="CASCADE"), nullable=False),
        sa.Column("rating", sa.Integer(), nullable=False),
        sa.Column("comment", sa.String(2000), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("order_id", name="uq_reviews_order_id"),
    )
    op.create_index("ix_reviews_id", "reviews", ["id"])
    op.create_index("ix_reviews_buyer_id", "reviews", ["buyer_id"])
    op.create_index("ix_reviews_product_id", "reviews", ["product_id"])


def downgrade() -> None:
    op.drop_table("reviews")
    op.drop_table("payments")
    op.drop_table("orders")
    op.drop_table("cart_items")
    op.drop_table("carts")
    op.drop_table("addresses")
    op.drop_table("products")
    op.drop_table("stock")
    op.drop_table("offers")
    op.drop_table("role_verifications")
    op.drop_table("users")

    # Drop enum types
    op.execute("DROP TYPE IF EXISTS payment_status_enum")
    op.execute("DROP TYPE IF EXISTS order_status_enum")
    op.execute("DROP TYPE IF EXISTS purchase_mode_enum")
    op.execute("DROP TYPE IF EXISTS product_status_enum")
    op.execute("DROP TYPE IF EXISTS offer_status_enum")
    op.execute("DROP TYPE IF EXISTS offer_unit_enum")
    op.execute("DROP TYPE IF EXISTS verification_status_enum")
    op.execute("DROP TYPE IF EXISTS role_type_enum")
    op.execute("DROP TYPE IF EXISTS active_role_enum")
