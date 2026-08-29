"""Shipping quotes and shipment tracking."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_verified_user, get_db_session
from app.models.operations import Shipment, ShipmentEvent, ShipmentStatus
from app.models.order import OrderStatus
from app.models.user import User
from app.schemas.operations import ShipmentResponse, ShippingRateRequest
from app.services.providers import maps_provider, shipping_provider

router = APIRouter()
shipment_router = APIRouter()


@router.get("/locations")
async def search_locations(q: str = Query(..., min_length=2), _: User = Depends(get_current_verified_user)):
    return await maps_provider().search(q)


@router.post("/rates")
async def get_rates(data: ShippingRateRequest, _: User = Depends(get_current_verified_user)):
    return await shipping_provider().rates(data.origin, data.destination, Decimal(str(data.weight_kg)))


async def _shipment_for_user(db: AsyncSession, shipment_id: uuid.UUID, user: User) -> Shipment:
    result = await db.execute(select(Shipment).where(Shipment.id == shipment_id).options(selectinload(Shipment.events), selectinload(Shipment.order)))
    shipment = result.scalar_one_or_none()
    if not shipment:
        raise HTTPException(404, "Shipment tidak ditemukan.")
    order = shipment.order
    if not user.is_admin and user.id not in {order.buyer_id, order.distributor_id}:
        raise HTTPException(403, "Akses shipment ditolak.")
    return shipment


@shipment_router.get("/{shipment_id}", response_model=ShipmentResponse)
async def shipment_detail(shipment_id: uuid.UUID, db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user)):
    return await _shipment_for_user(db, shipment_id, user)


@shipment_router.post("/{shipment_id}/refresh", response_model=ShipmentResponse)
async def refresh_tracking(shipment_id: uuid.UUID, db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user)):
    shipment = await _shipment_for_user(db, shipment_id, user)
    if not shipment.provider_order_id:
        raise HTTPException(409, "Shipment belum dibooking.")
    events = await shipping_provider().track(shipment.provider_order_id)
    for raw in events:
        event_id = str(raw.get("id") or uuid.uuid5(uuid.NAMESPACE_URL, str(raw)))
        exists = await db.scalar(select(ShipmentEvent.id).where(ShipmentEvent.shipment_id == shipment.id, ShipmentEvent.provider_event_id == event_id))
        if exists:
            continue
        try:
            event_status = ShipmentStatus(raw.get("status", "in_transit"))
        except ValueError:
            event_status = ShipmentStatus.IN_TRANSIT
        db.add(ShipmentEvent(
            shipment_id=shipment.id, provider_event_id=event_id, status=event_status,
            description=raw.get("description", "Tracking diperbarui"), location=raw.get("location"),
            occurred_at=datetime.now(timezone.utc),
        ))
        shipment.status = event_status
        if event_status in {ShipmentStatus.PICKED_UP, ShipmentStatus.IN_TRANSIT}:
            shipment.order.status = OrderStatus.DIKIRIM
        elif event_status == ShipmentStatus.DELIVERED:
            shipment.order.status = OrderStatus.SELESAI
    await db.commit()
    return await _shipment_for_user(db, shipment_id, user)


@shipment_router.post("/{shipment_id}/cancel", response_model=ShipmentResponse)
async def cancel_shipment(shipment_id: uuid.UUID, db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user)):
    shipment = await _shipment_for_user(db, shipment_id, user)
    if user.id != shipment.order.distributor_id and not user.is_admin:
        raise HTTPException(403, "Hanya distributor terkait atau admin yang dapat membatalkan shipment.")
    if shipment.status not in {ShipmentStatus.PENDING, ShipmentStatus.BOOKED}:
        raise HTTPException(409, "Shipment sudah dijemput dan tidak dapat dibatalkan.")
    if shipment.provider_order_id and not await shipping_provider().cancel(shipment.provider_order_id):
        raise HTTPException(502, "Provider gagal membatalkan shipment.")
    shipment.status = ShipmentStatus.CANCELLED
    await db.commit()
    return await _shipment_for_user(db, shipment_id, user)
