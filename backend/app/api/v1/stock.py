"""
Stock Router — Distributor stock management.
"""
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db_session, require_distributor
from app.models.user import User
from app.repositories.stock import stock_repository
from app.schemas.stock import StockAggregateResponse, StockResponse

router = APIRouter()


@router.get(
    "",
    response_model=List[StockResponse],
    summary="[Distributor] Daftar Stok",
)
async def get_my_stock(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Distributor melihat semua stok yang dimiliki."""
    stocks = await stock_repository.get_by_distributor(
        db, distributor_id=current_user.id, skip=skip, limit=limit
    )
    return [StockResponse.model_validate(s) for s in stocks]


@router.get(
    "/summary",
    response_model=List[StockAggregateResponse],
    summary="[Distributor] Ringkasan Stok per Kategori",
)
async def get_stock_summary(
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Ringkasan stok yang dikelompokkan per kategori."""
    return await stock_repository.get_aggregate_by_category(
        db, distributor_id=current_user.id
    )


@router.get(
    "/{stock_id}",
    response_model=StockResponse,
    summary="[Distributor] Detail Stok",
)
async def get_stock_detail(
    stock_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Detail stok tertentu."""
    import uuid
    try:
        sid = uuid.UUID(stock_id)
    except ValueError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="ID stok tidak valid.")

    stock = await stock_repository.get_by_id(db, stock_id=sid)
    if not stock:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Stok tidak ditemukan.")
    if stock.distributor_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Akses ditolak.")

    return StockResponse.model_validate(stock)
