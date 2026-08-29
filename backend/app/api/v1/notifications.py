"""In-app notification and device token API."""
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session
from app.models.operations import DeviceToken, Notification
from app.models.user import User
from app.schemas.operations import DeviceTokenCreate, NotificationResponse

router = APIRouter()
device_router = APIRouter()


@router.get("", response_model=list[NotificationResponse])
async def list_notifications(
    unread_only: bool = False, skip: int = Query(0, ge=0), limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user),
):
    query = select(Notification).where(Notification.user_id == user.id)
    if unread_only:
        query = query.where(Notification.read_at.is_(None))
    result = await db.execute(query.order_by(Notification.created_at.desc(), Notification.id).offset(skip).limit(limit))
    return list(result.scalars())


@router.patch("/{notification_id}/read", response_model=NotificationResponse)
async def mark_read(notification_id: uuid.UUID, db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user)):
    item = await db.get(Notification, notification_id)
    if not item or item.user_id != user.id:
        raise HTTPException(404, "Notifikasi tidak ditemukan.")
    item.read_at = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(item)
    return item


@device_router.post("", status_code=status.HTTP_201_CREATED)
async def register_device(data: DeviceTokenCreate, db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user)):
    result = await db.execute(select(DeviceToken).where(DeviceToken.token == data.token))
    device = result.scalar_one_or_none()
    if device:
        device.user_id = user.id
        device.platform = data.platform
        device.enabled = True
    else:
        device = DeviceToken(user_id=user.id, token=data.token, platform=data.platform)
        db.add(device)
    await db.commit()
    return {"id": str(device.id), "status": "registered"}


@device_router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device(device_id: uuid.UUID, db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user)):
    device = await db.get(DeviceToken, device_id)
    if not device or device.user_id != user.id:
        raise HTTPException(404, "Device tidak ditemukan.")
    await db.delete(device)
    await db.commit()
