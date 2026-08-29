"""
Review Service.
"""
import uuid

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.order import OrderStatus
from app.models.review import Review
from app.models.user import User
from app.repositories.order import order_repository
from app.repositories.review import review_repository
from app.schemas.review import ReviewCreate, ReviewResponse


class ReviewService:

    async def create_review(
        self,
        db: AsyncSession,
        *,
        buyer: User,
        data: ReviewCreate,
    ) -> ReviewResponse:
        """
        Create a review. Business rules:
        1. Order must exist and belong to buyer
        2. Order status must be 'selesai'
        3. No duplicate review for same order
        """
        order = await order_repository.get_by_id(db, order_id=data.order_id)
        if not order:
            raise ValueError("Pesanan tidak ditemukan.")
        if order.buyer_id != buyer.id:
            raise PermissionError("Anda tidak berhak memberi ulasan pada pesanan ini.")
        if order.status != OrderStatus.SELESAI:
            raise ValueError(
                "Ulasan hanya bisa diberikan setelah pesanan selesai."
            )

        # Check for existing review
        existing = await review_repository.get_by_order_id(db, order_id=data.order_id)
        if existing:
            raise ValueError("Anda sudah memberikan ulasan untuk pesanan ini.")

        review = Review(
            order_id=data.order_id,
            buyer_id=buyer.id,
            product_id=order.product_id,
            rating=data.rating,
            comment=data.comment,
        )
        review = await review_repository.create(db, review=review)

        resp = ReviewResponse.model_validate(review)
        resp.buyer_name = buyer.full_name
        return resp

    async def get_product_reviews(
        self,
        db: AsyncSession,
        *,
        product_id: uuid.UUID,
        skip: int = 0,
        limit: int = 20,
    ) -> list[ReviewResponse]:
        reviews = await review_repository.get_by_product(
            db, product_id=product_id, skip=skip, limit=limit
        )
        result = []
        for r in reviews:
            resp = ReviewResponse.model_validate(r)
            if r.buyer:
                resp.buyer_name = r.buyer.full_name
            result.append(resp)
        return result


review_service = ReviewService()
