from pathlib import Path
from decimal import Decimal

import pytest
from pydantic import ValidationError

from app.core.security import decrypt_sensitive, encrypt_sensitive, get_password_hash, mask_nik, verify_password
from app.core.storage import private_asset_path
from app.main import app
from app.models.order import PurchaseMode
from app.schemas.order import CheckoutRequest
from app.services.platform_service import post_ledger
from app.services.providers import FakePaymentProvider, FakeShippingProvider
from app.api.v1.payments import _find_payment


def test_password_and_sensitive_data_round_trip():
    hashed = get_password_hash("prototype-password")
    assert verify_password("prototype-password", hashed)
    assert not verify_password("wrong-password", hashed)

    encrypted = encrypt_sensitive("3212345678901234")
    assert encrypted != "3212345678901234"
    assert decrypt_sensitive(encrypted) == "3212345678901234"
    assert mask_nik(encrypted) == "************1234"


def test_checkout_rejects_duplicate_products():
    product_id = "43c664b9-8dde-48c5-a48d-06d2bc5a58c8"
    address_id = "5aa3fd6c-599a-4fb6-b037-fde5fc485f44"
    with pytest.raises(ValidationError, match="Produk yang sama"):
        CheckoutRequest.model_validate({
            "source": "buy_now",
            "items": [
                {"product_id": product_id, "quantity": 1, "purchase_mode": PurchaseMode.RETAIL},
                {"product_id": product_id, "quantity": 2, "purchase_mode": PurchaseMode.RETAIL},
            ],
            "shipping_address_id": address_id,
            "payment_method": "fake",
            "idempotency_key": "checkout-test-key",
        })


def test_private_asset_reference_blocks_traversal(tmp_path, monkeypatch):
    from app.core.config import settings

    monkeypatch.setattr(settings, "PRIVATE_UPLOAD_DIR", str(tmp_path))
    assert private_asset_path("private://ktp/example.jpg") == Path(tmp_path, "ktp/example.jpg").resolve()
    with pytest.raises(ValueError):
        private_asset_path("private://../secret")


def test_required_api_groups_are_in_openapi():
    paths = app.openapi()["paths"]
    expected = {
        "/api/v1/admin/verifications",
        "/api/v1/admin/users",
        "/api/v1/admin/disputes",
        "/api/v1/admin/ml/train",
        "/api/v1/shipments/{shipment_id}",
        "/api/v1/shipping/locations",
        "/api/v1/notifications",
        "/api/v1/devices",
        "/api/v1/dashboards/petani",
        "/api/v1/dashboards/distributor",
        "/api/v1/ledger",
        "/api/v1/payouts",
        "/api/v1/disputes",
        "/api/v1/prices/history",
        "/api/v1/prices/predict",
    }
    assert expected <= paths.keys()


@pytest.mark.asyncio
async def test_ledger_rejects_unbalanced_entries_before_database_write():
    with pytest.raises(ValueError, match="seimbang"):
        await post_ledger(
            None,
            reference_type="test",
            reference_id="unbalanced",
            description="invalid ledger",
            entries=[("debit", None, Decimal("100")), ("credit", None, Decimal("-99"))],
        )


@pytest.mark.asyncio
async def test_fake_providers_are_deterministic():
    payment = FakePaymentProvider()
    first = await payment.create(
        external_order_id="CROPCHAIN-TEST",
        amount=Decimal("10000"),
        customer={"email": "buyer@example.com"},
        item_name="Cabai",
    )
    second = await payment.create(
        external_order_id="CROPCHAIN-TEST",
        amount=Decimal("10000"),
        customer={"email": "buyer@example.com"},
        item_name="Cabai",
    )
    assert first == second

    shipping = FakeShippingProvider()
    rates = await shipping.rates({}, {}, Decimal("2"))
    assert rates[0]["fee"] == 11500.0
    assert await shipping.cancel("FAKE-ORDER")


@pytest.mark.asyncio
async def test_payment_lookup_accepts_payment_order_and_offer_ids():
    class Result:
        def scalar_one_or_none(self):
            return None

    class Session:
        statement = None

        async def execute(self, statement):
            self.statement = statement
            return Result()

    session = Session()
    await _find_payment(session, __import__("uuid").uuid4())
    sql = str(session.statement)
    assert "payments.id" in sql
    assert "payments.order_id" in sql
    assert "payments.offer_id" in sql
