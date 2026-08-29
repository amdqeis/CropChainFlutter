"""Buyer dispute workflow with admin resolution."""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session, require_admin
from app.core.config import settings
from app.models.operations import Dispute, DisputeStatus
from app.models.order import Order, OrderStatus
from app.models.payment import Payment, PaymentStatus
from app.models.user import User
from app.schemas.operations import DisputeCreate, DisputeResolve, DisputeResponse
from app.services.platform_service import audit, notify, post_ledger
from app.services.providers import payment_provider
from app.services.order_service import order_service

router = APIRouter()
admin_router = APIRouter(dependencies=[Depends(require_admin)])


@router.post("", response_model=DisputeResponse, status_code=status.HTTP_201_CREATED)
async def create_dispute(data: DisputeCreate, db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user)):
    order = await db.get(Order, data.order_id)
    if not order or order.buyer_id != user.id:
        raise HTTPException(404, "Pesanan tidak ditemukan.")
    if order.status != OrderStatus.SELESAI:
        raise HTTPException(409, "Dispute hanya dapat dibuat untuk pesanan selesai.")
    if order.updated_at < datetime.now(timezone.utc) - timedelta(days=settings.DISPUTE_WINDOW_DAYS):
        raise HTTPException(409, "Periode pengajuan dispute telah berakhir.")
    existing = await db.scalar(select(Dispute.id).where(Dispute.order_id == order.id, Dispute.status.in_([DisputeStatus.OPEN, DisputeStatus.IN_REVIEW])))
    if existing:
        raise HTTPException(409, "Masih ada dispute aktif untuk pesanan ini.")
    dispute = Dispute(opened_by_id=user.id, order_id=order.id, category=data.category, description=data.description, evidence=data.evidence)
    db.add(dispute)
    await db.flush()
    await audit(db, action="dispute.opened", entity_type="dispute", entity_id=dispute.id, actor_id=user.id)
    await notify(db, user_id=order.distributor_id, kind="dispute", title="Dispute baru", body=f"Dispute dibuka untuk pesanan {order.id}.")
    await db.commit()
    await db.refresh(dispute)
    return dispute


@router.get("", response_model=list[DisputeResponse])
@admin_router.get("", response_model=list[DisputeResponse])
async def list_disputes(
    skip: int = Query(0, ge=0), limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user),
):
    query = select(Dispute).join(Order)
    if not user.is_admin:
        query = query.where(or_(Dispute.opened_by_id == user.id, Order.distributor_id == user.id))
    result = await db.execute(query.order_by(Dispute.created_at.desc(), Dispute.id).offset(skip).limit(limit))
    return list(result.scalars())


@router.patch("/{dispute_id}/resolve", response_model=DisputeResponse)
@admin_router.patch("/{dispute_id}/resolve", response_model=DisputeResponse)
async def resolve_dispute(
    dispute_id: uuid.UUID, data: DisputeResolve,
    db: AsyncSession = Depends(get_db_session), admin: User = Depends(require_admin),
):
    if data.status not in {DisputeStatus.RESOLVED, DisputeStatus.REJECTED}:
        raise HTTPException(422, "Status akhir harus resolved atau rejected.")
    dispute = await db.get(Dispute, dispute_id, with_for_update=True)
    if not dispute or dispute.status not in {DisputeStatus.OPEN, DisputeStatus.IN_REVIEW}:
        raise HTTPException(409, "Dispute tidak ditemukan atau sudah selesai.")
    order = await db.get(Order, dispute.order_id)
    if data.refund_approved:
        payment = await db.scalar(select(Payment).where(Payment.checkout_group_id == order.checkout_group_id))
        if not payment or not await payment_provider().refund(payment.midtrans_order_id, Decimal(str(order.total_price))):
            raise HTTPException(502, "Provider gagal memproses refund.")
        await order_service.restore_order_inventory(db, order.id)
        order.status = OrderStatus.DIBATALKAN
        sibling = await db.scalar(select(Order.id).where(
            Order.checkout_group_id == order.checkout_group_id,
            Order.id != order.id,
            Order.status != OrderStatus.DIBATALKAN,
        ).limit(1))
        payment.status = PaymentStatus.BERHASIL if sibling else PaymentStatus.REFUNDED
        amount = Decimal(str(order.total_price))
        distributor_amount = amount - Decimal(str(order.platform_fee))
        await post_ledger(db, reference_type="dispute_refund", reference_id=dispute.id, description="Refund dispute", entries=[
            ("buyer_refund", order.buyer_id, amount),
            ("distributor_revenue", order.distributor_id, -distributor_amount),
            ("platform_revenue", None, -Decimal(str(order.platform_fee))),
        ])
    dispute.status = data.status
    dispute.resolution = data.resolution
    dispute.refund_approved = data.refund_approved
    dispute.assigned_admin_id = admin.id
    await audit(db, action=f"dispute.{data.status.value}", entity_type="dispute", entity_id=dispute.id, actor_id=admin.id)
    await notify(db, user_id=dispute.opened_by_id, kind="dispute", title="Dispute diselesaikan", body=data.resolution)
    await db.commit()
    await db.refresh(dispute)
    return dispute
