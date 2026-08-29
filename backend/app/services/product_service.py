"""
Product Service.
Business logic for creating and managing marketplace product listings.
"""
import uuid
from decimal import Decimal
from typing import List, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.product import Product, ProductStatus
from app.models.stock import Stock, StockStatus
from app.models.commerce import ProductStockAllocation
from app.services.platform_service import audit
from app.models.user import User
from app.repositories.product import product_repository
from app.schemas.product import (
    DistributorInfo,
    FarmerOriginInfo,
    ProductCreate,
    ProductResponse,
    ProductUpdate,
)


async def _enrich_product(db: AsyncSession, product: Product) -> ProductResponse:
    """Build enriched ProductResponse with distributor and optional farmer info."""
    resp = ProductResponse.model_validate(product)

    # Distributor info
    if product.distributor:
        resp.distributor_info = DistributorInfo(
            id=product.distributor.id,
            full_name=product.distributor.full_name,
        )

    # Farmer origin — only if show_farmer_info is True and stock/offer/petani loaded
    if product.show_farmer_info and product.stock and product.stock.offer:
        offer = product.stock.offer
        if offer.petani:
            resp.farmer_origin_info = FarmerOriginInfo(
                petani_id=offer.petani.id,
                petani_name=offer.petani.full_name,
                offer_location=offer.location,
                category=offer.category,
            )
    if product.show_farmer_info:
        seen = set()
        for allocation in product.allocations:
            offer = allocation.stock.offer if allocation.stock else None
            if not offer or not offer.petani or offer.petani_id in seen:
                continue
            seen.add(offer.petani_id)
            resp.farmer_origins.append(FarmerOriginInfo(
                petani_id=offer.petani.id,
                petani_name=offer.petani.full_name,
                offer_location=offer.location,
                category=offer.category,
            ))
        if resp.farmer_origin_info and not resp.farmer_origins:
            resp.farmer_origins.append(resp.farmer_origin_info)

    # Reviews summary
    if product.reviews:
        resp.review_count = len(product.reviews)
        if resp.review_count > 0:
            resp.average_rating = sum(r.rating for r in product.reviews) / resp.review_count

    return resp


class ProductService:

    async def create_product(
        self,
        db: AsyncSession,
        *,
        distributor: User,
        data: ProductCreate,
    ) -> ProductResponse:
        """Create a new product listing from a distributor's stock."""
        requested = data.allocations or []
        if not requested and data.stock_id:
            from app.schemas.product import StockAllocationInput
            requested = [StockAllocationInput(stock_id=data.stock_id, quantity=data.stock_remaining)]
        locked_stocks = []
        from sqlalchemy import select
        for item in requested:
            result = await db.execute(select(Stock).where(Stock.id == item.stock_id).with_for_update())
            stock = result.scalar_one_or_none()
            if not stock or stock.distributor_id != distributor.id:
                raise ValueError("Stok tidak ditemukan atau bukan milik Anda.")
            if stock.status != StockStatus.ACTIVE:
                raise ValueError("Stok belum aktif; pembayaran Petani harus berhasil dahulu.")
            available = Decimal(str(stock.quantity_available)) - Decimal(str(stock.quantity_reserved))
            if available < Decimal(str(item.quantity)):
                raise ValueError(f"Stok {stock.id} tidak mencukupi. Tersedia: {available} kg")
            if stock.category.casefold() != data.category.casefold():
                raise ValueError("Kategori semua stok harus sama dengan kategori produk.")
            locked_stocks.append((stock, item))

        product = Product(
            distributor_id=distributor.id,
            stock_id=locked_stocks[0][0].id if len(locked_stocks) == 1 else None,
            name=data.name,
            category=data.category,
            description=data.description,
            public_price=data.public_price,
            wholesale_price=data.wholesale_price,
            location=data.location,
            photo=data.photo,
            show_farmer_info=data.show_farmer_info,
            stock_remaining=data.stock_remaining,
            stock_reserved=0,
            unit="kg",
            status=ProductStatus.AKTIF,
        )
        db.add(product)
        await db.flush()
        for stock, item in locked_stocks:
            stock.quantity_reserved = Decimal(str(stock.quantity_reserved)) + Decimal(str(item.quantity))
            db.add(ProductStockAllocation(product_id=product.id, stock_id=stock.id, allocated_quantity=item.quantity, consumed_quantity=0))
        await audit(db, action="product.created", entity_type="product", entity_id=product.id, actor_id=distributor.id)
        await db.commit()
        loaded = await product_repository.get_by_id(db, product_id=product.id)
        return await _enrich_product(db, loaded)

    async def update_product(
        self,
        db: AsyncSession,
        *,
        product_id: uuid.UUID,
        distributor: User,
        data: ProductUpdate,
    ) -> ProductResponse:
        product = await product_repository.get_by_id(db, product_id=product_id)
        if not product:
            raise ValueError("Produk tidak ditemukan.")
        if product.distributor_id != distributor.id:
            raise PermissionError("Anda tidak berhak mengubah produk ini.")

        if data.category and data.category.casefold() != product.category.casefold():
            raise ValueError("Kategori produk tidak dapat diubah karena terikat pada allocation stok.")

        update_data = data.model_dump(exclude_none=True)
        product = await product_repository.update(db, product=product, **update_data)
        return ProductResponse.model_validate(product)

    async def delete_product(
        self,
        db: AsyncSession,
        *,
        product_id: uuid.UUID,
        distributor: User,
    ) -> None:
        product = await product_repository.get_by_id(db, product_id=product_id)
        if not product:
            raise ValueError("Produk tidak ditemukan.")
        if product.distributor_id != distributor.id:
            raise PermissionError("Anda tidak berhak menghapus produk ini.")
        from sqlalchemy import func, select
        from app.models.order import Order
        order_count = await db.scalar(select(func.count(Order.id)).where(Order.product_id == product.id))
        if order_count:
            product.status = ProductStatus.NONAKTIF
        else:
            allocations = await db.execute(select(ProductStockAllocation).where(ProductStockAllocation.product_id == product.id))
            for allocation in allocations.scalars():
                stock = await db.get(Stock, allocation.stock_id, with_for_update=True)
                remaining = Decimal(str(allocation.allocated_quantity)) - Decimal(str(allocation.consumed_quantity))
                stock.quantity_reserved = max(Decimal("0"), Decimal(str(stock.quantity_reserved)) - remaining)
            await db.delete(product)
        await audit(db, action="product.deleted", entity_type="product", entity_id=product_id, actor_id=distributor.id)
        await db.commit()

    async def get_marketplace(
        self,
        db: AsyncSession,
        *,
        category: Optional[str] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> List[ProductResponse]:
        """Get active marketplace products for buyer browsing."""
        products = await product_repository.get_active_marketplace(
            db, category=category, skip=skip, limit=limit
        )
        return [ProductResponse.model_validate(p) for p in products]

    async def search_products(
        self,
        db: AsyncSession,
        *,
        query: str,
        skip: int = 0,
        limit: int = 50,
    ) -> List[ProductResponse]:
        products = await product_repository.search(
            db, query=query, skip=skip, limit=limit
        )
        return [ProductResponse.model_validate(p) for p in products]

    async def get_product_detail(
        self, db: AsyncSession, *, product_id: uuid.UUID
    ) -> ProductResponse:
        """Get full product detail with distributor info, optional farmer trace, and reviews."""
        product = await product_repository.get_by_id(db, product_id=product_id)
        if not product:
            raise ValueError("Produk tidak ditemukan.")
        return await _enrich_product(db, product)

    async def get_distributor_products(
        self, db: AsyncSession, *, distributor: User, skip: int = 0, limit: int = 50
    ) -> List[ProductResponse]:
        products = await product_repository.get_by_distributor(
            db, distributor_id=distributor.id, skip=skip, limit=limit
        )
        return [ProductResponse.model_validate(p) for p in products]


product_service = ProductService()
