"""
Stock repository.
"""
import uuid
from datetime import datetime, timezone
from typing import List

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.stock import Stock


class StockRepository:

    async def create_from_offer(
        self,
        db: AsyncSession,
        *,
        distributor_id: uuid.UUID,
        offer_id: uuid.UUID,
        category: str,
        quantity_available: float,
    ) -> Stock:
        """Auto-create stock record when an offer is accepted."""
        stock = Stock(
            distributor_id=distributor_id,
            offer_id=offer_id,
            category=category,
            quantity_available=quantity_available,
            received_at=datetime.now(timezone.utc),
        )
        db.add(stock)
        await db.commit()
        await db.refresh(stock)
        return stock

    async def get_by_id(self, db: AsyncSession, *, stock_id: uuid.UUID) -> Stock | None:
        result = await db.execute(select(Stock).where(Stock.id == stock_id))
        return result.scalar_one_or_none()

    async def get_by_distributor(
        self, db: AsyncSession, *, distributor_id: uuid.UUID, skip: int = 0, limit: int = 50
    ) -> List[Stock]:
        """Get all stock records for a distributor."""
        result = await db.execute(
            select(Stock)
            .where(Stock.distributor_id == distributor_id)
            .order_by(Stock.received_at.desc(), Stock.id)
            .offset(skip)
            .limit(limit)
        )
        return list(result.scalars().all())

    async def get_aggregate_by_category(
        self, db: AsyncSession, *, distributor_id: uuid.UUID
    ) -> List[dict]:
        """
        Return aggregated quantity per category for the distributor dashboard.
        Result: [{"category": "...", "total_quantity_available": x, "stock_count": n}]
        """
        result = await db.execute(
            select(
                Stock.category,
                func.sum(Stock.quantity_available).label("total_quantity_available"),
                func.count(Stock.id).label("stock_count"),
            )
            .where(Stock.distributor_id == distributor_id)
            .group_by(Stock.category)
            .order_by(Stock.category)
        )
        return [
            {
                "category": row.category,
                "total_quantity_available": float(row.total_quantity_available),
                "stock_count": row.stock_count,
            }
            for row in result.all()
        ]

    async def reduce_quantity(
        self, db: AsyncSession, *, stock: Stock, amount: float
    ) -> Stock:
        """Reduce available quantity when a product is sold."""
        stock.quantity_available = max(0, float(stock.quantity_available) - amount)
        await db.commit()
        await db.refresh(stock)
        return stock


stock_repository = StockRepository()
