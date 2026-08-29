"""
Product repository.
"""
import uuid
from typing import List, Optional

from sqlalchemy import func, or_, select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.product import Product, ProductStatus
from app.models.stock import Stock
from app.models.offer import Offer
from app.models.commerce import ProductStockAllocation


class ProductRepository:

    async def create(self, db: AsyncSession, *, product: Product) -> Product:
        db.add(product)
        await db.commit()
        await db.refresh(product)
        return product

    async def get_by_id(
        self, db: AsyncSession, *, product_id: uuid.UUID
    ) -> Optional[Product]:
        result = await db.execute(
            select(Product)
            .where(Product.id == product_id)
            .options(
                selectinload(Product.distributor),
                selectinload(Product.stock).selectinload(Stock.offer).selectinload(Offer.petani),
                selectinload(Product.allocations).selectinload(ProductStockAllocation.stock).selectinload(Stock.offer).selectinload(Offer.petani),
                selectinload(Product.reviews),
            )
        )
        return result.scalar_one_or_none()

    async def get_active_marketplace(
        self,
        db: AsyncSession,
        *,
        category: Optional[str] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> List[Product]:
        """Get all active products for the marketplace, optionally filtered by category."""
        query = select(Product).where(Product.status == ProductStatus.AKTIF)
        if category:
            query = query.where(Product.category.ilike(f"%{category}%"))
        query = (
            query
            .options(selectinload(Product.distributor))
            .options(selectinload(Product.reviews))
            .order_by(Product.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        result = await db.execute(query)
        return list(result.scalars().all())

    async def search(
        self,
        db: AsyncSession,
        *,
        query: str,
        skip: int = 0,
        limit: int = 50,
    ) -> List[Product]:
        """Search active products by name or category."""
        result = await db.execute(
            select(Product)
            .where(
                Product.status == ProductStatus.AKTIF,
                or_(
                    Product.name.ilike(f"%{query}%"),
                    Product.category.ilike(f"%{query}%"),
                ),
            )
            .options(selectinload(Product.distributor))
            .options(selectinload(Product.reviews))
            .order_by(Product.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return list(result.scalars().all())

    async def get_by_distributor(
        self, db: AsyncSession, *, distributor_id: uuid.UUID, skip: int = 0, limit: int = 50
    ) -> List[Product]:
        """Get all products owned by a distributor."""
        result = await db.execute(
            select(Product)
            .where(Product.distributor_id == distributor_id)
            .options(selectinload(Product.reviews))
            .order_by(Product.created_at.desc(), Product.id)
            .offset(skip)
            .limit(limit)
        )
        return list(result.scalars().all())

    async def update(self, db: AsyncSession, *, product: Product, **kwargs) -> Product:
        for field, value in kwargs.items():
            if hasattr(product, field) and value is not None:
                setattr(product, field, value)
        await db.commit()
        await db.refresh(product)
        return product

    async def delete(self, db: AsyncSession, *, product: Product) -> None:
        await db.delete(product)
        await db.commit()

    async def reduce_stock(
        self, db: AsyncSession, *, product: Product, amount: float
    ) -> Product:
        """Reduce stock_remaining after a successful order."""
        product.stock_remaining = max(0, float(product.stock_remaining) - amount)
        if float(product.stock_remaining) == 0:
            product.status = ProductStatus.NONAKTIF
        await db.commit()
        await db.refresh(product)
        return product

    async def get_average_rating(
        self, db: AsyncSession, *, product_id: uuid.UUID
    ) -> Optional[float]:
        from app.models.review import Review
        result = await db.execute(
            select(func.avg(Review.rating)).where(Review.product_id == product_id)
        )
        avg = result.scalar_one_or_none()
        return float(avg) if avg is not None else None


product_repository = ProductRepository()
