"""
Offers Router.
Endpoints for Petani (create, list, accept/reject nego) and Distributor (view incoming, negotiate, accept, reject).
"""
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db_session, require_distributor, require_petani
from app.models.offer import OfferStatus
from app.models.user import User
from app.schemas.offer import OfferCreate, OfferNegotiate, OfferResponse
from app.services.offer_service import offer_service

router = APIRouter()


# =====================================================================
# PETANI ENDPOINTS
# =====================================================================

@router.post(
    "",
    response_model=OfferResponse,
    status_code=status.HTTP_201_CREATED,
    summary="[Petani] Buat Tawaran Baru",
)
async def create_offer(
    data: OfferCreate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_petani),
):
    """
    Petani membuat tawaran hasil panen baru.
    Status awal: `menunggu`.
    """
    try:
        return await offer_service.create_offer(db, petani=current_user, data=data)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "/my-offers",
    response_model=List[OfferResponse],
    summary="[Petani] Daftar Tawaran Saya",
)
async def get_my_offers(
    status_filter: Optional[OfferStatus] = Query(None, alias="status"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_petani),
):
    """
    Petani melihat semua tawaran yang pernah dibuat.
    Filter opsional: `menunggu`, `setuju_harga_baru`, `diterima`, `tolak`, `selesai`.
    """
    return await offer_service.get_petani_offers(
        db, petani_id=current_user.id, status=status_filter, skip=skip, limit=limit
    )


@router.patch(
    "/{offer_id}/accept",
    response_model=OfferResponse,
    summary="[Petani] Terima Harga Negosiasi",
)
async def petani_accept_offer(
    offer_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_petani),
):
    """
    Petani menerima harga negosiasi dari distributor.
    Hanya berlaku untuk offer berstatus `setuju_harga_baru`.
    """
    import uuid
    try:
        oid = uuid.UUID(offer_id)
        return await offer_service.accept_offer(
            db, offer_id=oid, actor=current_user, distributor_id=None
        )
    except (ValueError, PermissionError) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.patch(
    "/{offer_id}/reject",
    response_model=OfferResponse,
    summary="[Petani] Tolak Tawaran/Negosiasi",
)
async def petani_reject_offer(
    offer_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_petani),
):
    """Petani menolak tawaran atau hasil negosiasi."""
    import uuid
    try:
        oid = uuid.UUID(offer_id)
        return await offer_service.reject_offer(db, offer_id=oid, actor=current_user)
    except (ValueError, PermissionError) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


# =====================================================================
# DISTRIBUTOR ENDPOINTS
# =====================================================================

@router.get(
    "/incoming",
    response_model=List[OfferResponse],
    summary="[Distributor] Lihat Tawaran Masuk",
)
async def get_incoming_offers(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """
    Distributor melihat semua tawaran dari petani yang masih open
    (status: `menunggu` atau `setuju_harga_baru`).
    """
    return await offer_service.get_incoming_offers(
        db, distributor_id=current_user.id, skip=skip, limit=limit
    )


@router.patch(
    "/{offer_id}/negotiate",
    response_model=OfferResponse,
    summary="[Distributor] Negosiasi Harga",
)
async def negotiate_offer(
    offer_id: str,
    data: OfferNegotiate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """
    Distributor mengajukan harga negosiasi.
    Offer status berubah ke `setuju_harga_baru`, petani harus merespons.
    """
    import uuid
    try:
        oid = uuid.UUID(offer_id)
        return await offer_service.negotiate(
            db, offer_id=oid, distributor=current_user,
            negotiated_price=data.negotiated_price
        )
    except (ValueError, PermissionError) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.patch(
    "/{offer_id}/accept-direct",
    response_model=OfferResponse,
    summary="[Distributor] Terima Langsung (Tanpa Nego)",
)
async def distributor_accept_offer(
    offer_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """
    Distributor menerima tawaran langsung tanpa negosiasi.
    Stok otomatis masuk ke inventory distributor.
    """
    import uuid
    try:
        oid = uuid.UUID(offer_id)
        return await offer_service.accept_offer(
            db, offer_id=oid, actor=current_user, distributor_id=current_user.id
        )
    except (ValueError, PermissionError) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.patch(
    "/{offer_id}/reject-distributor",
    response_model=OfferResponse,
    summary="[Distributor] Tolak Tawaran",
)
async def distributor_reject_offer(
    offer_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(require_distributor),
):
    """Distributor menolak tawaran dari petani."""
    import uuid
    try:
        oid = uuid.UUID(offer_id)
        return await offer_service.reject_offer(db, offer_id=oid, actor=current_user)
    except (ValueError, PermissionError) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
