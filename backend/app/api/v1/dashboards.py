"""Financial and operational summaries derived from source-of-truth tables."""

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session, require_distributor, require_petani
from app.models.offer import Offer
from app.models.operations import LedgerEntry, Payout
from app.models.order import Order
from app.models.stock import Stock, StockStatus
from app.models.user import User
from app.services.platform_service import user_balance

router = APIRouter()
finance_router = APIRouter()


@router.get("/petani")
async def petani_dashboard(db: AsyncSession = Depends(get_db_session), user: User = Depends(require_petani)):
    balance = await user_balance(db, user.id)
    offer_counts = await db.execute(select(Offer.status, func.count(Offer.id)).where(Offer.petani_id == user.id).group_by(Offer.status))
    paid = await db.scalar(select(func.coalesce(func.sum(Payout.amount), 0)).where(Payout.user_id == user.id))
    return {"balance": float(balance), "total_paid": float(paid or 0), "offers": {status.value: count for status, count in offer_counts}}


@router.get("/distributor")
async def distributor_dashboard(db: AsyncSession = Depends(get_db_session), user: User = Depends(require_distributor)):
    revenue = await db.scalar(select(func.coalesce(func.sum(LedgerEntry.amount), 0)).where(LedgerEntry.user_id == user.id, LedgerEntry.account_code == "distributor_revenue"))
    stock = await db.execute(select(Stock.category, func.sum(Stock.quantity_available - Stock.quantity_reserved)).where(Stock.distributor_id == user.id, Stock.status == StockStatus.ACTIVE).group_by(Stock.category))
    orders = await db.execute(select(Order.status, func.count(Order.id)).where(Order.distributor_id == user.id).group_by(Order.status))
    return {
        "net_revenue": float(revenue or 0),
        "stock_by_category": {category: float(quantity) for category, quantity in stock},
        "orders": {status.value: count for status, count in orders},
        "note": "Margin dihitung dari ledger penjualan; biaya pembelian stok tersedia pada ledger pembayaran Petani.",
    }


@finance_router.get("/ledger")
async def my_ledger(
    skip: int = Query(0, ge=0), limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user),
):
    result = await db.execute(select(LedgerEntry).where(LedgerEntry.user_id == user.id).order_by(LedgerEntry.id.desc()).offset(skip).limit(limit))
    return [{"id": str(entry.id), "account": entry.account_code, "amount": float(entry.amount), "transaction_id": str(entry.transaction_id)} for entry in result.scalars()]


@finance_router.get("/payouts")
async def my_payouts(
    skip: int = Query(0, ge=0), limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session), user: User = Depends(get_current_verified_user),
):
    result = await db.execute(select(Payout).where(Payout.user_id == user.id).order_by(Payout.created_at.desc(), Payout.id).offset(skip).limit(limit))
    return [{"id": str(item.id), "payment_id": str(item.payment_id), "amount": float(item.amount), "status": item.status.value, "paid_at": item.paid_at} for item in result.scalars()]
