"""
Address repository.
"""
import uuid
from typing import List, Optional

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.address import Address


class AddressRepository:

    async def create(self, db: AsyncSession, *, address: Address) -> Address:
        # If is_default=True, unset all other defaults for this user first
        if address.is_default:
            await self._unset_defaults(db, user_id=address.user_id)
        db.add(address)
        await db.commit()
        await db.refresh(address)
        return address

    async def get_by_id(
        self, db: AsyncSession, *, address_id: uuid.UUID
    ) -> Optional[Address]:
        result = await db.execute(select(Address).where(Address.id == address_id))
        return result.scalar_one_or_none()

    async def get_by_user(
        self, db: AsyncSession, *, user_id: uuid.UUID
    ) -> List[Address]:
        result = await db.execute(
            select(Address)
            .where(Address.user_id == user_id)
            .order_by(Address.is_default.desc(), Address.created_at.desc())
        )
        return list(result.scalars().all())

    async def update(
        self, db: AsyncSession, *, address: Address, **kwargs
    ) -> Address:
        if kwargs.get("is_default"):
            await self._unset_defaults(db, user_id=address.user_id)
        for field, value in kwargs.items():
            if hasattr(address, field) and value is not None:
                setattr(address, field, value)
        await db.commit()
        await db.refresh(address)
        return address

    async def delete(self, db: AsyncSession, *, address: Address) -> None:
        await db.delete(address)
        await db.commit()

    async def set_default(
        self, db: AsyncSession, *, address: Address
    ) -> Address:
        await self._unset_defaults(db, user_id=address.user_id)
        address.is_default = True
        await db.commit()
        await db.refresh(address)
        return address

    async def _unset_defaults(self, db: AsyncSession, *, user_id: uuid.UUID) -> None:
        """Remove is_default=True from all addresses of a user."""
        await db.execute(
            update(Address)
            .where(Address.user_id == user_id, Address.is_default.is_(True))
            .values(is_default=False)
        )
        await db.flush()


address_repository = AddressRepository()
