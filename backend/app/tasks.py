"""Idempotent background tasks."""
import asyncio
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import select

from app.core.database import AsyncSessionLocal
from app.core.config import settings
from app.models.commerce import CheckoutGroup, CheckoutStatus, InventoryReservation, ReservationStatus
from app.models.operations import DeviceToken, Notification, Shipment, ShipmentEvent, ShipmentStatus
from app.models.payment import Payment, PaymentStatus
from app.models.product import Product
from app.models.order import Order, OrderStatus
from app.services.providers import notification_provider, shipping_provider
from app.worker import celery_app


def _run(coro):
    return asyncio.run(coro)


@celery_app.task(name="app.tasks.worker_heartbeat")
def worker_heartbeat():
    return _run(_worker_heartbeat())


async def _worker_heartbeat() -> bool:
    import redis.asyncio as aioredis

    redis = aioredis.from_url(settings.REDIS_URL, encoding="utf-8", decode_responses=True)
    await redis.setex("cropchain:worker:heartbeat", 90, datetime.now(timezone.utc).isoformat())
    await redis.aclose()
    return True


@celery_app.task(name="app.tasks.release_expired_reservations")
def release_expired_reservations():
    return _run(_release_expired())


async def _release_expired() -> int:
    count = 0
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(InventoryReservation).where(
            InventoryReservation.status == ReservationStatus.ACTIVE,
            InventoryReservation.expires_at < datetime.now(timezone.utc),
        ).with_for_update(skip_locked=True))
        for reservation in result.scalars():
            product = await db.get(Product, reservation.product_id, with_for_update=True)
            product.stock_reserved = max(Decimal("0"), Decimal(str(product.stock_reserved)) - Decimal(str(reservation.quantity)))
            reservation.status = ReservationStatus.RELEASED
            group = await db.get(CheckoutGroup, reservation.checkout_group_id)
            group.status = CheckoutStatus.FAILED
            payment = await db.scalar(select(Payment).where(Payment.checkout_group_id == group.id))
            if payment and payment.status == PaymentStatus.MENUNGGU:
                payment.status = PaymentStatus.GAGAL
            count += 1
        await db.commit()
    return count


@celery_app.task(name="app.tasks.deliver_notifications")
def deliver_notifications():
    return _run(_deliver_notifications())


async def _deliver_notifications() -> int:
    delivered = 0
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(Notification).where(
            Notification.delivered_at.is_(None), Notification.attempts < 5
        ).order_by(Notification.created_at).limit(100).with_for_update(skip_locked=True))
        for item in result.scalars():
            tokens = list((await db.execute(select(DeviceToken.token).where(DeviceToken.user_id == item.user_id, DeviceToken.enabled.is_(True)))).scalars())
            try:
                await notification_provider().send(tokens, item.title, item.body, item.payload)
                item.delivered_at = datetime.now(timezone.utc)
                delivered += 1
            except Exception as exc:
                item.attempts += 1
                item.last_error = str(exc)[:1000]
        await db.commit()
    return delivered


@celery_app.task(name="app.tasks.refresh_shipments")
def refresh_shipments():
    return _run(_refresh_shipments())


async def _refresh_shipments() -> int:
    updated = 0
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(Shipment).where(
            Shipment.provider_order_id.is_not(None),
            Shipment.status.in_([ShipmentStatus.BOOKED, ShipmentStatus.PICKED_UP, ShipmentStatus.IN_TRANSIT]),
        ).limit(100))
        for shipment in result.scalars():
            for raw in await shipping_provider().track(shipment.provider_order_id):
                event_id = str(raw.get("id"))
                if await db.scalar(select(ShipmentEvent.id).where(ShipmentEvent.shipment_id == shipment.id, ShipmentEvent.provider_event_id == event_id)):
                    continue
                try:
                    new_status = ShipmentStatus(raw.get("status"))
                except ValueError:
                    new_status = ShipmentStatus.IN_TRANSIT
                db.add(ShipmentEvent(
                    shipment_id=shipment.id, provider_event_id=event_id,
                    status=new_status, description=raw.get("description", "Tracking diperbarui"),
                    location=raw.get("location"), occurred_at=datetime.now(timezone.utc),
                ))
                shipment.status = new_status
                order = await db.get(Order, shipment.order_id, with_for_update=True)
                if order and new_status in {ShipmentStatus.PICKED_UP, ShipmentStatus.IN_TRANSIT}:
                    order.status = OrderStatus.DIKIRIM
                elif order and new_status == ShipmentStatus.DELIVERED:
                    order.status = OrderStatus.SELESAI
                updated += 1
        await db.commit()
    return updated
