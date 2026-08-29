"""
Orders Router — Checkout, order management, and status updates.
"""
import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session, require_distributor, require_pembeli
from app.models.order import OrderStatus
from app.models.user import User
from app.schemas.order import CheckoutRequest, CheckoutResponse, OrderResponse
from app.services.order_service import order_service

router = APIRouter()


@router.post(
    "/checkout",
    response_model=CheckoutResponse,
    status_code=status.HTTP_201_CREATED,
    summary="[Pembeli] Checkout & Bayar",
)
async def checkout(
    data: CheckoutRequest,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_pembeli),
):
    """
    Proses checkout:
    1. Validasi produk, alamat, stok
    2. Hitung total harga (harga + ongkir + fee platform)
    3. Buat Order + Payment (menunggu)
    4. Buat transaksi Midtrans Snap
    5. Return snap_token untuk pembayaran di frontend
    """
    try:
        return await order_service.checkout(db, buyer=current_user, data=data)
    except (ValueError, PermissionError) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "",
    response_model=List[OrderResponse],
    summary="[Pembeli] Pesanan Saya",
)
async def get_my_orders(
    status_filter: Optional[OrderStatus] = Query(None, alias="status"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_pembeli),
):
    """
    Pembeli melihat semua pesanan.
    Filter: `diproses`, `dikirim`, `selesai`, `dibatalkan`.
    """
    return await order_service.get_buyer_orders(
        db, buyer=current_user, status=status_filter, skip=skip, limit=limit
    )


@router.get(
    "/incoming",
    response_model=List[OrderResponse],
    summary="[Distributor] Pesanan Masuk",
)
async def get_incoming_orders(
    status_filter: Optional[OrderStatus] = Query(None, alias="status"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """
    Distributor melihat semua pesanan yang masuk.
    Filter: `diproses`, `dikirim`, `selesai`, `dibatalkan`.
    """
    return await order_service.get_distributor_orders(
        db, distributor=current_user, status=status_filter, skip=skip, limit=limit
    )


@router.get(
    "/{order_id}",
    response_model=OrderResponse,
    summary="Detail Pesanan",
)
async def get_order_detail(
    order_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Detail pesanan tertentu (hanya pembeli atau distributor terkait yang bisa akses)."""
    from app.repositories.order import order_repository
    try:
        oid = uuid.UUID(order_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID pesanan tidak valid.")

    order = await order_repository.get_by_id(db, order_id=oid)
    if not order:
        raise HTTPException(status_code=404, detail="Pesanan tidak ditemukan.")

    # Authorization: only buyer or distributor of this order
    if order.buyer_id != current_user.id and order.distributor_id != current_user.id:
        raise HTTPException(status_code=403, detail="Akses ditolak.")

    return OrderResponse.model_validate(order)


@router.patch(
    "/{order_id}/cancel",
    response_model=OrderResponse,
    summary="[Pembeli] Batalkan Pesanan",
)
async def cancel_order(
    order_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_pembeli),
):
    """
    Pembeli membatalkan pesanan.
    Hanya bisa saat status `diproses`.
    Jika pembayaran sudah berhasil, refund otomatis diproses via Midtrans.
    """
    try:
        oid = uuid.UUID(order_id)
        return await order_service.cancel_order(db, order_id=oid, buyer=current_user)
    except (ValueError, PermissionError) as e:
        code = status.HTTP_403_FORBIDDEN if isinstance(e, PermissionError) else status.HTTP_400_BAD_REQUEST
        raise HTTPException(status_code=code, detail=str(e))


@router.patch(
    "/{order_id}/mark-shipped",
    response_model=OrderResponse,
    summary="[Distributor] Tandai Dikirim",
)
async def mark_shipped(
    order_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Distributor menandai pesanan sudah dikirim → status `dikirim`."""
    try:
        oid = uuid.UUID(order_id)
        return await order_service.mark_shipped(db, order_id=oid, distributor=current_user)
    except (ValueError, PermissionError) as e:
        code = status.HTTP_403_FORBIDDEN if isinstance(e, PermissionError) else status.HTTP_400_BAD_REQUEST
        raise HTTPException(status_code=code, detail=str(e))


@router.patch(
    "/{order_id}/mark-done",
    response_model=OrderResponse,
    summary="[Distributor] Tandai Selesai",
)
async def mark_done(
    order_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Distributor menandai pesanan selesai diterima → status `selesai`."""
    try:
        oid = uuid.UUID(order_id)
        return await order_service.mark_done(db, order_id=oid, distributor=current_user)
    except (ValueError, PermissionError) as e:
        code = status.HTTP_403_FORBIDDEN if isinstance(e, PermissionError) else status.HTTP_400_BAD_REQUEST
        raise HTTPException(status_code=code, detail=str(e))
