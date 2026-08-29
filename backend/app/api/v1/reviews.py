"""
Reviews Router.
"""
import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session
from app.models.user import User
from app.schemas.review import ReviewCreate, ReviewResponse
from app.services.review_service import review_service

router = APIRouter()


@router.post(
    "",
    response_model=ReviewResponse,
    status_code=status.HTTP_201_CREATED,
    summary="[Pembeli] Beri Ulasan",
)
async def create_review(
    data: ReviewCreate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """
    Beri ulasan untuk produk yang sudah dibeli.
    Hanya bisa dilakukan setelah pesanan berstatus `selesai`.
    Satu ulasan per pesanan.
    """
    try:
        return await review_service.create_review(db, buyer=current_user, data=data)
    except (ValueError, PermissionError) as e:
        code = status.HTTP_403_FORBIDDEN if isinstance(e, PermissionError) else status.HTTP_400_BAD_REQUEST
        raise HTTPException(status_code=code, detail=str(e))


@router.get(
    "/product/{product_id}",
    response_model=List[ReviewResponse],
    summary="Ulasan Produk",
)
async def get_product_reviews(
    product_id: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
):
    """Ambil semua ulasan untuk sebuah produk (akses publik)."""
    try:
        pid = uuid.UUID(product_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID produk tidak valid.")

    return await review_service.get_product_reviews(
        db, product_id=pid, skip=skip, limit=limit
    )
