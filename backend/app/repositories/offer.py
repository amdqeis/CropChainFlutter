"""
Offer repository.
"""
import uuid
from typing import List, Optional

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.offer import Offer, OfferStatus


class OfferRepository:

    async def create(self, db: AsyncSession, *, offer: Offer) -> Offer:
        db.add(offer)
        await db.commit()
        await db.refresh(offer)
        return offer

    async def get_by_id(self, db: AsyncSession, *, offer_id: uuid.UUID) -> Optional[Offer]:
        result = await db.execute(
            select(Offer)
            .where(Offer.id == offer_id)
            .options(selectinload(Offer.petani))
        )
        return result.scalar_one_or_none()

    async def get_by_petani(
        self,
        db: AsyncSession,
        *,
        petani_id: uuid.UUID,
        status: Optional[OfferStatus] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> List[Offer]:
        """Get offers created by a specific petani, optionally filtered by status."""
        query = select(Offer).where(Offer.petani_id == petani_id)
        if status:
            query = query.where(Offer.status == status)
        query = query.order_by(Offer.created_at.desc(), Offer.id).offset(skip).limit(limit)
        result = await db.execute(query)
        return list(result.scalars().all())

    async def get_incoming_for_distributor(
        self,
        db: AsyncSession,
        *,
        status_filter: Optional[List[OfferStatus]] = None,
    ) -> List[Offer]:
        """
        Get all open/negotiated offers visible to distributors.
        If status_filter is None, returns menunggu + setuju_harga_baru.
        """
        if status_filter is None:
            status_filter = [OfferStatus.MENUNGGU, OfferStatus.SETUJU_HARGA_BARU]
        query = (
            select(Offer)
            .where(Offer.status.in_(status_filter))
            .options(selectinload(Offer.petani))
            .order_by(Offer.created_at.desc())
        )
        result = await db.execute(query)
        return list(result.scalars().all())

    async def update_status(
        self,
        db: AsyncSession,
        *,
        offer: Offer,
        status: OfferStatus,
        negotiated_price: Optional[float] = None,
    ) -> Offer:
        offer.status = status
        if negotiated_price is not None:
            offer.negotiated_price = negotiated_price
        await db.commit()
        await db.refresh(offer)
        return offer

    async def get_selesai_by_petani(
        self, db: AsyncSession, *, petani_id: uuid.UUID
    ) -> List[Offer]:
        """Get all completed (selesai) offers for a petani — for saldo summary."""
        result = await db.execute(
            select(Offer).where(
                Offer.petani_id == petani_id,
                Offer.status == OfferStatus.SELESAI,
            )
        )
        return list(result.scalars().all())


offer_repository = OfferRepository()
