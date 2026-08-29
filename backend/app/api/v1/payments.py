"""Payment status, retry, provider webhook, and guarded demo transitions."""
import hashlib
import hmac
import uuid
from decimal import Decimal, InvalidOperation

from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_verified_user, get_db_session
from app.core.config import settings
from app.models.commerce import PaymentAttempt
from app.models.order import Order
from app.models.payment import Payment
from app.models.user import User
from app.schemas.payment import MidtransWebhookPayload, PaymentResponse
from app.services.payment_flow import payment_flow
from app.services.providers import payment_provider

router = APIRouter()


async def _find_payment(db: AsyncSession, value: uuid.UUID) -> Payment | None:
    # Offer payments are created as part of accepting a farmer offer. Supporting
    # offer_id here lets the mobile client resolve that payment without exposing
    # a second lookup endpoint or changing the response contract.
    result = await db.execute(
        select(Payment)
        .where(or_(Payment.id == value, Payment.order_id == value, Payment.offer_id == value))
        .options(selectinload(Payment.attempts))
    )
    return result.scalar_one_or_none()


async def _authorized(db: AsyncSession, payment: Payment, user: User) -> bool:
    if user.is_admin or payment.payer_id == user.id or payment.payee_id == user.id:
        return True
    if payment.checkout_group_id:
        result = await db.execute(select(Order.id).where(Order.checkout_group_id == payment.checkout_group_id, Order.distributor_id == user.id).limit(1))
        return result.scalar_one_or_none() is not None
    return False


@router.get("/{payment_or_order_id}", response_model=PaymentResponse, summary="Status Pembayaran")
async def get_payment_status(
    payment_or_order_id: uuid.UUID, db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    payment = await _find_payment(db, payment_or_order_id)
    if not payment:
        raise HTTPException(404, "Data pembayaran tidak ditemukan.")
    if not await _authorized(db, payment, current_user):
        raise HTTPException(403, "Akses pembayaran ditolak.")
    return payment


@router.post("/{payment_or_order_id}/retry", response_model=PaymentResponse)
async def retry_payment(
    payment_or_order_id: uuid.UUID, db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    payment = await _find_payment(db, payment_or_order_id)
    if not payment:
        raise HTTPException(404, "Data pembayaran tidak ditemukan.")
    try:
        return await payment_flow.retry(db, payment=payment, payer=current_user)
    except PermissionError as exc:
        raise HTTPException(403, str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(409, str(exc)) from exc


@router.post("/webhook/midtrans", include_in_schema=False)
async def midtrans_webhook(payload: MidtransWebhookPayload, db: AsyncSession = Depends(get_db_session)):
    raw = payload.order_id + (payload.status_code or "") + payload.gross_amount + settings.MIDTRANS_SERVER_KEY
    expected_signature = hashlib.sha512(raw.encode()).hexdigest()
    if not settings.MIDTRANS_SERVER_KEY or not hmac.compare_digest(expected_signature, payload.signature_key):
        raise HTTPException(400, "Signature Midtrans tidak valid.")
    attempt = await db.scalar(
        select(PaymentAttempt)
        .where(PaymentAttempt.external_order_id == payload.order_id)
        .options(selectinload(PaymentAttempt.payment))
    )
    if not attempt:
        raise HTTPException(404, "Payment attempt tidak ditemukan.")
    try:
        reported_amount = Decimal(payload.gross_amount).quantize(Decimal("0.01"))
    except InvalidOperation as exc:
        raise HTTPException(400, "Nominal webhook tidak valid.") from exc
    if reported_amount != Decimal(str(attempt.payment.amount)).quantize(Decimal("0.01")):
        raise HTTPException(409, "Nominal webhook tidak sesuai.")
    provider_status = await payment_provider().status(payload.order_id)
    reported = payload.transaction_status
    if provider_status not in {reported, "capture" if reported == "settlement" else reported}:
        raise HTTPException(409, "Status provider tidak konsisten.")
    outcome = "success" if reported in {"capture", "settlement"} and payload.fraud_status != "challenge" else "failed"
    await payment_flow.transition(db, external_order_id=payload.order_id, outcome=outcome)
    return {"status": "ok"}


@router.post("/demo/{external_order_id}/{outcome}", include_in_schema=True)
async def demo_transition(
    external_order_id: str, outcome: str, x_demo_key: str = Header("", alias="X-Demo-Key"),
    db: AsyncSession = Depends(get_db_session),
):
    if settings.APP_ENV == "production" or settings.PAYMENT_PROVIDER != "fake":
        raise HTTPException(404, "Route demo tidak tersedia.")
    if not settings.DEMO_API_KEY or not hmac.compare_digest(x_demo_key, settings.DEMO_API_KEY):
        raise HTTPException(403, "Demo key tidak valid.")
    try:
        payment = await payment_flow.transition(db, external_order_id=external_order_id, outcome=outcome)
        return {"payment_id": str(payment.id), "status": payment.status.value}
    except ValueError as exc:
        raise HTTPException(status.HTTP_409_CONFLICT, str(exc)) from exc
