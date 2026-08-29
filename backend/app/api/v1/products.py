"""
Products Router — Marketplace product listing management.
"""
import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db_session, require_distributor
from app.models.user import User
from app.schemas.product import ProductCreate, ProductResponse, ProductUpdate
from app.services.product_service import product_service

router = APIRouter()


# ─── Public Endpoints (Buyer / All) ──────────────────────────────────────────

@router.get(
    "",
    response_model=List[ProductResponse],
    summary="[Publik] Daftar Produk Marketplace",
)
async def get_marketplace_products(
    category: Optional[str] = Query(None, description="Filter berdasarkan kategori"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
):
    """Semua produk aktif di marketplace (akses publik)."""
    return await product_service.get_marketplace(
        db, category=category, skip=skip, limit=limit
    )


@router.get(
    "/search",
    response_model=List[ProductResponse],
    summary="[Publik] Cari Produk",
)
async def search_products(
    q: str = Query(..., min_length=2, description="Kata kunci pencarian"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
):
    """Cari produk berdasarkan nama atau kategori."""
    return await product_service.search_products(db, query=q, skip=skip, limit=limit)


@router.get(
    "/{product_id:uuid}",
    response_model=ProductResponse,
    summary="[Publik] Detail Produk",
)
async def get_product_detail(
    product_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session),
):
    """Detail produk beserta info distributor, ulasan, dan (jika diizinkan) info petani asal."""
    try:
        return await product_service.get_product_detail(db, product_id=product_id)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


# ─── Distributor Endpoints ────────────────────────────────────────────────────

@router.get(
    "/distributor/me",
    response_model=List[ProductResponse],
    summary="[Distributor] Produk Saya",
)
async def get_my_products(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Distributor melihat semua produk yang ia jual."""
    return await product_service.get_distributor_products(
        db, distributor=current_user, skip=skip, limit=limit
    )


@router.post(
    "",
    response_model=ProductResponse,
    status_code=status.HTTP_201_CREATED,
    summary="[Distributor] Buat Produk Baru",
)
async def create_product(
    data: ProductCreate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """
    Distributor membuat listing produk dari stok.
    Stok yang dipilih harus milik distributor yang login.
    """
    try:
        return await product_service.create_product(
            db, distributor=current_user, data=data
        )
    except (ValueError, PermissionError) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.patch(
    "/{product_id}",
    response_model=ProductResponse,
    summary="[Distributor] Update Produk",
)
async def update_product(
    product_id: str,
    data: ProductUpdate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Distributor mengubah informasi produk (hanya produk miliknya)."""
    try:
        pid = uuid.UUID(product_id)
        return await product_service.update_product(
            db, product_id=pid, distributor=current_user, data=data
        )
    except (ValueError, PermissionError) as e:
        code = status.HTTP_403_FORBIDDEN if isinstance(e, PermissionError) else status.HTTP_400_BAD_REQUEST
        raise HTTPException(status_code=code, detail=str(e))


@router.delete(
    "/{product_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="[Distributor] Hapus Produk",
)
async def delete_product(
    product_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Distributor menghapus produk miliknya."""
    try:
        pid = uuid.UUID(product_id)
        await product_service.delete_product(
            db, product_id=pid, distributor=current_user
        )
    except (ValueError, PermissionError) as e:
        code = status.HTTP_403_FORBIDDEN if isinstance(e, PermissionError) else status.HTTP_400_BAD_REQUEST
        raise HTTPException(status_code=code, detail=str(e))
