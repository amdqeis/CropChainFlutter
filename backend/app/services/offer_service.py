"""
Offer Service.
Business logic for the Petani → Distributor offer flow.
"""
import uuid
from datetime import datetime, timezone
from typing import List, Optional

from decimal import Decimal
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.offer import Offer, OfferStatus
from app.models.user import User
from app.models.stock import Stock, StockStatus
from app.models.payment import PaymentPurpose
from app.repositories.offer import offer_repository
from app.schemas.offer import OfferCreate, OfferResponse
from app.services.payment_flow import payment_flow
from app.services.platform_service import audit, notify


def _to_response(offer: Offer) -> OfferResponse:
    """Convert Offer ORM object to response schema."""
    resp = OfferResponse.model_validate(offer)
    petani = offer.__dict__.get("petani")
    if petani:
        resp.petani_name = petani.full_name
    return resp


class OfferService:

    async def create_offer(
        self,
        db: AsyncSession,
        *,
        petani: User,
        data: OfferCreate,
    ) -> OfferResponse:
        """Petani creates a new harvest offer."""
        offer = Offer(
            petani_id=petani.id,
            category=data.category,
            quantity=data.quantity,
            quantity_kg=Decimal(str(data.quantity)) * (Decimal("1000") if data.unit.value == "ton" else Decimal("1")),
            unit=data.unit,
            proposed_price=data.proposed_price,
            location=data.location,
            photo=data.photo,
            notes=data.notes,
            status=OfferStatus.MENUNGGU,
        )
        offer = await offer_repository.create(db, offer=offer)
        return _to_response(offer)

    async def get_petani_offers(
        self,
        db: AsyncSession,
        *,
        petani_id: uuid.UUID,
        status: Optional[OfferStatus] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> List[OfferResponse]:
        """List all offers by a petani, optionally filtered by status."""
        offers = await offer_repository.get_by_petani(
            db, petani_id=petani_id, status=status, skip=skip, limit=limit
        )
        return [_to_response(o) for o in offers]

    async def get_incoming_offers(
        self,
        db: AsyncSession,
        *,
        status_filter: Optional[List[OfferStatus]] = None,
        distributor_id: Optional[uuid.UUID] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> List[OfferResponse]:
        """Distributor views open offers from all petani."""
        statuses = status_filter or [OfferStatus.MENUNGGU, OfferStatus.SETUJU_HARGA_BARU]
        result = await db.execute(
            select(Offer).where(
                Offer.status.in_(statuses),
                or_(Offer.distributor_id.is_(None), Offer.distributor_id == distributor_id),
            ).order_by(Offer.created_at.desc(), Offer.id).offset(skip).limit(limit)
        )
        offers = list(result.scalars())
        return [_to_response(o) for o in offers]

    async def negotiate(
        self,
        db: AsyncSession,
        *,
        offer_id: uuid.UUID,
        distributor: User,
        negotiated_price: float,
    ) -> OfferResponse:
        """
        Distributor proposes a new price.
        Rules (SRS §10): Distributor can only negotiate once per cycle.
        """
        result = await db.execute(select(Offer).where(Offer.id == offer_id).with_for_update())
        offer = result.scalar_one_or_none()
        if not offer:
            raise ValueError("Offer tidak ditemukan.")

        if offer.status != OfferStatus.MENUNGGU:
            raise ValueError(
                f"Offer tidak bisa dinegosiasi karena statusnya adalah '{offer.status.value}'. "
                "Hanya offer berstatus 'menunggu' yang bisa dinegosiasi."
            )
        if offer.distributor_id and offer.distributor_id != distributor.id:
            raise PermissionError("Offer sudah diklaim distributor lain.")

        offer.distributor_id = distributor.id
        offer.status = OfferStatus.SETUJU_HARGA_BARU
        offer.negotiated_price = negotiated_price
        await audit(db, action="offer.negotiated", entity_type="offer", entity_id=offer.id, actor_id=distributor.id)
        await notify(db, user_id=offer.petani_id, kind="offer", title="Harga baru diajukan", body=f"Distributor mengajukan harga Rp{negotiated_price:,.0f}.")
        await db.commit()
        await db.refresh(offer)
        return _to_response(offer)

    async def accept_offer(
        self,
        db: AsyncSession,
        *,
        offer_id: uuid.UUID,
        actor: User,
        distributor_id: Optional[uuid.UUID] = None,
    ) -> OfferResponse:
        """
        Accept an offer. Two scenarios:
        1. Distributor accepts directly (status: menunggu → diterima)
        2. Petani accepts distributor's negotiated price (status: setuju_harga_baru → diterima)

        After acceptance, auto-create Stock for distributor.
        distributor_id is required when distributor is accepting.
        """
        result = await db.execute(select(Offer).where(Offer.id == offer_id).with_for_update())
        offer = result.scalar_one_or_none()
        if not offer:
            raise ValueError("Offer tidak ditemukan.")

        # Validate actor and allowed current statuses
        if actor.id == offer.petani_id:
            # Petani accepts distributor's negotiated price
            if offer.status != OfferStatus.SETUJU_HARGA_BARU:
                raise ValueError(
                    "Hanya offer dengan status 'setuju_harga_baru' yang bisa diterima oleh petani."
                )
            if offer.petani_id != actor.id:
                raise PermissionError("Offer bukan milik Anda.")
            actual_distributor_id = offer.distributor_id
        else:
            # Distributor accepts directly
            if offer.status != OfferStatus.MENUNGGU:
                raise ValueError(
                    "Hanya offer dengan status 'menunggu' yang bisa langsung diterima oleh distributor."
                )
            actual_distributor_id = actor.id

        if actual_distributor_id is None:
            raise ValueError("distributor_id diperlukan.")

        offer.distributor_id = actual_distributor_id
        offer.status = OfferStatus.DITERIMA
        stock = Stock(
            distributor_id=actual_distributor_id, offer_id=offer.id,
            category=offer.category, quantity_available=offer.quantity_kg,
            quantity_reserved=0, unit="kg", status=StockStatus.PENDING_PAYMENT,
            received_at=datetime.now(timezone.utc),
        )
        db.add(stock)
        await db.flush()
        distributor = actor if actor.id == actual_distributor_id else await db.get(User, actual_distributor_id)
        final_price = Decimal(str(offer.negotiated_price or offer.proposed_price))
        await payment_flow.create(
            db, payer=distributor, payee_id=offer.petani_id,
            amount=final_price * Decimal(str(offer.quantity)),
            purpose=PaymentPurpose.FARMER_OFFER,
            idempotency_key=f"offer-{offer.id}", offer_id=offer.id,
            item_name=f"Pembelian {offer.category}",
            commit=False,
        )
        await db.commit()
        await db.refresh(offer)

        return _to_response(offer)

    async def reject_offer(
        self,
        db: AsyncSession,
        *,
        offer_id: uuid.UUID,
        actor: User,
    ) -> OfferResponse:
        """
        Reject an offer. Allowed by both petani and distributor
        when status is 'menunggu' or 'setuju_harga_baru'.
        """
        result = await db.execute(select(Offer).where(Offer.id == offer_id).with_for_update())
        offer = result.scalar_one_or_none()
        if not offer:
            raise ValueError("Offer tidak ditemukan.")

        allowed_statuses = [OfferStatus.MENUNGGU, OfferStatus.SETUJU_HARGA_BARU]
        if offer.status not in allowed_statuses:
            raise ValueError(
                f"Offer dengan status '{offer.status.value}' tidak bisa ditolak."
            )

        if actor.id == offer.petani_id:
            offer.status = OfferStatus.TOLAK
        else:
            if offer.distributor_id and offer.distributor_id != actor.id:
                raise PermissionError("Offer diklaim distributor lain.")
            if offer.distributor_id == actor.id:
                offer.distributor_id = None
                offer.negotiated_price = None
                offer.status = OfferStatus.MENUNGGU
        await audit(db, action="offer.rejected", entity_type="offer", entity_id=offer.id, actor_id=actor.id)
        await db.commit()
        await db.refresh(offer)
        return _to_response(offer)


offer_service = OfferService()
