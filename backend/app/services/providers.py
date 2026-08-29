"""External provider adapters with deterministic prototype implementations."""
import hashlib
import uuid
from dataclasses import dataclass
from decimal import Decimal
from typing import Any, Protocol

import httpx

from app.core.config import settings


@dataclass
class PaymentSession:
    token: str
    redirect_url: str


class PaymentProvider(Protocol):
    async def create(self, *, external_order_id: str, amount: Decimal, customer: dict, item_name: str) -> PaymentSession: ...
    async def status(self, external_order_id: str) -> str: ...
    async def refund(self, external_order_id: str, amount: Decimal) -> bool: ...


class FakePaymentProvider:
    async def create(self, *, external_order_id: str, amount: Decimal, customer: dict, item_name: str) -> PaymentSession:
        digest = hashlib.sha256(external_order_id.encode()).hexdigest()[:20]
        return PaymentSession(f"fake-{digest}", f"http://localhost:8000/demo/pay/{external_order_id}")

    async def status(self, external_order_id: str) -> str:
        return "pending"

    async def refund(self, external_order_id: str, amount: Decimal) -> bool:
        return True


class MidtransPaymentProvider:
    async def create(self, *, external_order_id: str, amount: Decimal, customer: dict, item_name: str) -> PaymentSession:
        import asyncio
        import midtransclient
        snap = midtransclient.Snap(is_production=settings.MIDTRANS_IS_PRODUCTION, server_key=settings.MIDTRANS_SERVER_KEY)
        payload = {
            "transaction_details": {"order_id": external_order_id, "gross_amount": int(amount)},
            "customer_details": customer,
            "item_details": [{"id": external_order_id, "price": int(amount), "quantity": 1, "name": item_name[:50]}],
        }
        result = await asyncio.to_thread(snap.create_transaction, payload)
        return PaymentSession(result["token"], result["redirect_url"])

    async def status(self, external_order_id: str) -> str:
        import asyncio
        import midtransclient
        core = midtransclient.CoreApi(is_production=settings.MIDTRANS_IS_PRODUCTION, server_key=settings.MIDTRANS_SERVER_KEY)
        result = await asyncio.to_thread(core.transactions.status, external_order_id)
        return result.get("transaction_status", "pending")

    async def refund(self, external_order_id: str, amount: Decimal) -> bool:
        import asyncio
        import midtransclient
        core = midtransclient.CoreApi(is_production=settings.MIDTRANS_IS_PRODUCTION, server_key=settings.MIDTRANS_SERVER_KEY)
        await asyncio.to_thread(core.transactions.refund, external_order_id, {"amount": int(amount)})
        return True


def payment_provider() -> PaymentProvider:
    return MidtransPaymentProvider() if settings.PAYMENT_PROVIDER == "midtrans" else FakePaymentProvider()


class ShippingProvider(Protocol):
    async def locations(self, query: str) -> list[dict]: ...
    async def rates(self, origin: dict, destination: dict, weight_kg: Decimal) -> list[dict]: ...
    async def book(self, payload: dict) -> dict: ...
    async def track(self, provider_order_id: str) -> list[dict]: ...
    async def cancel(self, provider_order_id: str) -> bool: ...


class FakeShippingProvider:
    async def locations(self, query: str) -> list[dict]:
        return [{"id": "sumedang-demo", "label": f"{query.title()}, Kabupaten Sumedang", "postal_code": "45311"}]

    async def rates(self, origin: dict, destination: dict, weight_kg: Decimal) -> list[dict]:
        base = Decimal("10000") + weight_kg * Decimal("750")
        return [
            {"rate_id": "fake-regular", "courier": "CropExpress", "service": "REG", "fee": float(base), "eta_days": 3},
            {"rate_id": "fake-express", "courier": "CropExpress", "service": "EXP", "fee": float(base * Decimal("1.5")), "eta_days": 1},
        ]

    async def book(self, payload: dict) -> dict:
        value = uuid.uuid5(uuid.NAMESPACE_URL, str(payload))
        return {"provider_order_id": f"FAKE-{value.hex[:12]}", "awb": f"CC{value.hex[:14].upper()}", "status": "booked"}

    async def track(self, provider_order_id: str) -> list[dict]:
        return [{"id": f"{provider_order_id}-booked", "status": "booked", "description": "Shipment booked", "location": "Sumedang"}]

    async def cancel(self, provider_order_id: str) -> bool:
        return True


class ShipperProvider:
    def __init__(self) -> None:
        self.headers = {"X-API-Key": settings.SHIPPER_API_KEY, "Content-Type": "application/json"}

    async def _request(self, method: str, path: str, **kwargs) -> Any:
        async with httpx.AsyncClient(base_url=settings.SHIPPER_BASE_URL, headers=self.headers, timeout=15) as client:
            response = await client.request(method, path, **kwargs)
            response.raise_for_status()
            return response.json()

    async def locations(self, query: str) -> list[dict]:
        data = await self._request("GET", "/v3/location", params={"adm_name": query})
        return data.get("data", [])

    async def rates(self, origin: dict, destination: dict, weight_kg: Decimal) -> list[dict]:
        data = await self._request("POST", "/v3/pricing/domestic", json={"origin": origin, "destination": destination, "weight": int(weight_kg * 1000)})
        return data.get("data", {}).get("pricings", [])

    async def book(self, payload: dict) -> dict:
        data = await self._request("POST", "/v3/order", json=payload)
        return data.get("data", data)

    async def track(self, provider_order_id: str) -> list[dict]:
        data = await self._request("GET", f"/v3/order/{provider_order_id}")
        return data.get("data", {}).get("trackings", [])

    async def cancel(self, provider_order_id: str) -> bool:
        await self._request("DELETE", f"/v3/order/{provider_order_id}")
        return True


def shipping_provider() -> ShippingProvider:
    return ShipperProvider() if settings.SHIPPING_PROVIDER == "shipper" else FakeShippingProvider()


class MapsProvider(Protocol):
    async def search(self, query: str) -> list[dict]: ...


class FakeMapsProvider:
    async def search(self, query: str) -> list[dict]:
        return [{"id": "sumedang-demo", "label": f"{query.title()}, Kabupaten Sumedang", "postal_code": "45311", "latitude": -6.8586, "longitude": 107.9205}]


class GoogleMapsProvider:
    async def search(self, query: str) -> list[dict]:
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get("https://maps.googleapis.com/maps/api/geocode/json", params={"address": query, "key": settings.GOOGLE_MAPS_API_KEY, "region": "id"})
            response.raise_for_status()
            output = []
            for item in response.json().get("results", []):
                location = item["geometry"]["location"]
                postal = next((part["long_name"] for part in item["address_components"] if "postal_code" in part["types"]), None)
                output.append({"id": item["place_id"], "label": item["formatted_address"], "postal_code": postal, "latitude": location["lat"], "longitude": location["lng"]})
            return output


def maps_provider() -> MapsProvider:
    return GoogleMapsProvider() if settings.MAPS_PROVIDER == "google" else FakeMapsProvider()


class NotificationProvider(Protocol):
    async def send(self, tokens: list[str], title: str, body: str, payload: dict) -> None: ...


class FakeNotificationProvider:
    async def send(self, tokens: list[str], title: str, body: str, payload: dict) -> None:
        return None


class FCMNotificationProvider:
    async def send(self, tokens: list[str], title: str, body: str, payload: dict) -> None:
        if not tokens:
            return
        import asyncio
        import firebase_admin
        from firebase_admin import credentials, messaging
        if not firebase_admin._apps:
            firebase_admin.initialize_app(credentials.Certificate(settings.FCM_CREDENTIALS_PATH))
        message = messaging.MulticastMessage(
            tokens=tokens, notification=messaging.Notification(title=title, body=body),
            data={str(k): str(v) for k, v in payload.items()},
        )
        await asyncio.to_thread(messaging.send_each_for_multicast, message)


def notification_provider() -> NotificationProvider:
    return FCMNotificationProvider() if settings.NOTIFICATION_PROVIDER == "fcm" else FakeNotificationProvider()
