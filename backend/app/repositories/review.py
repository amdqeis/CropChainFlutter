"""
Review repository.
"""
import uuid
from typing import List, Optional

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.review import Review


class ReviewRepository:

    async def create(self, db: AsyncSession, *, review: Review) -> Review:
        db.add(review)
        await db.commit()
        await db.refresh(review)
        return review

    async def get_by_order_id(
        self, db: AsyncSession, *, order_id: uuid.UUID
    ) -> Optional[Review]:
        result = await db.execute(
            select(Review).where(Review.order_id == order_id)
        )
        return result.scalar_one_or_none()

    async def get_by_product(
        self,
        db: AsyncSession,
        *,
        product_id: uuid.UUID,
        skip: int = 0,
        limit: int = 20,
    ) -> List[Review]:
        result = await db.execute(
            select(Review)
            .where(Review.product_id == product_id)
            .options(selectinload(Review.buyer))
            .order_by(Review.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return list(result.scalars().all())


review_repository = ReviewRepository()
