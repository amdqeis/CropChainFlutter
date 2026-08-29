"""
Addresses Router — Saved shipping addresses for buyers.
"""
import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session
from app.models.address import Address
from app.models.user import User
from app.repositories.address import address_repository
from app.schemas.address import AddressCreate, AddressResponse, AddressUpdate

router = APIRouter()


@router.get("", response_model=List[AddressResponse], summary="Daftar Alamat Tersimpan")
async def get_addresses(
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Ambil semua alamat tersimpan milik user yang login."""
    addresses = await address_repository.get_by_user(db, user_id=current_user.id)
    return [AddressResponse.model_validate(a) for a in addresses]


@router.post(
    "",
    response_model=AddressResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Tambah Alamat Baru",
)
async def create_address(
    data: AddressCreate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Tambahkan alamat pengiriman baru."""
    address = Address(
        user_id=current_user.id,
        label=data.label,
        recipient_name=data.recipient_name,
        phone=data.phone,
        full_address=data.full_address,
        postal_code=data.postal_code,
        district=data.district,
        city=data.city,
        province=data.province,
        latitude=data.latitude,
        longitude=data.longitude,
        is_default=data.is_default,
    )
    address = await address_repository.create(db, address=address)
    return AddressResponse.model_validate(address)


@router.patch("/{address_id}", response_model=AddressResponse, summary="Update Alamat")
async def update_address(
    address_id: str,
    data: AddressUpdate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Update informasi alamat tersimpan."""
    try:
        aid = uuid.UUID(address_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID alamat tidak valid.")

    address = await address_repository.get_by_id(db, address_id=aid)
    if not address or address.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Alamat tidak ditemukan.")

    update_data = data.model_dump(exclude_none=True)
    address = await address_repository.update(db, address=address, **update_data)
    return AddressResponse.model_validate(address)


@router.delete(
    "/{address_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Hapus Alamat",
)
async def delete_address(
    address_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Hapus alamat tersimpan."""
    try:
        aid = uuid.UUID(address_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID alamat tidak valid.")

    address = await address_repository.get_by_id(db, address_id=aid)
    if not address or address.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Alamat tidak ditemukan.")

    await address_repository.delete(db, address=address)


@router.patch(
    "/{address_id}/set-default",
    response_model=AddressResponse,
    summary="Set Alamat Default",
)
async def set_default_address(
    address_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Jadikan alamat ini sebagai alamat default pengiriman."""
    try:
        aid = uuid.UUID(address_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID alamat tidak valid.")

    address = await address_repository.get_by_id(db, address_id=aid)
    if not address or address.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Alamat tidak ditemukan.")

    address = await address_repository.set_default(db, address=address)
    return AddressResponse.model_validate(address)
