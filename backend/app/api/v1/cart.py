"""
Cart Router — Shopping cart management for buyers.
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session
from app.models.user import User
from app.repositories.cart import cart_repository
from app.repositories.product import product_repository
from app.schemas.cart import CartItemAdd, CartItemUpdate, CartResponse

router = APIRouter()


@router.get("", response_model=CartResponse, summary="Lihat Keranjang")
async def get_cart(
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Tampilkan isi keranjang beserta total harga."""
    cart = await cart_repository.get_cart_with_items(db, user_id=current_user.id)
    if not cart:
        # Return empty cart
        return CartResponse(
            id=uuid.uuid4(),
            user_id=current_user.id,
            items=[],
            total_items=0,
            subtotal=0.0,
        )

    # Calculate subtotal (using public_price by default)
    subtotal = sum(
        float(item.quantity) * float(item.product.public_price)
        for item in cart.items
        if item.product
    )

    return CartResponse(
        id=cart.id,
        user_id=cart.user_id,
        items=cart.items,
        total_items=len(cart.items),
        subtotal=subtotal,
    )


@router.post(
    "/items",
    status_code=status.HTTP_201_CREATED,
    summary="Tambah ke Keranjang",
)
async def add_to_cart(
    data: CartItemAdd,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Tambah produk ke keranjang. Jika sudah ada, jumlah akan ditambahkan."""
    # Validate product
    product = await product_repository.get_by_id(db, product_id=data.product_id)
    if not product or product.status.value != "aktif":
        raise HTTPException(status_code=404, detail="Produk tidak ditemukan atau tidak aktif.")
    available = float(product.stock_remaining) - float(product.stock_reserved)
    cart = await cart_repository.get_or_create_cart(db, user_id=current_user.id)
    existing = await cart_repository.get_cart_item(db, cart_id=cart.id, product_id=data.product_id)
    requested_total = data.quantity + (float(existing.quantity) if existing else 0)
    if available < requested_total:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Stok tidak mencukupi. Tersedia: {available} kg",
        )
    item = await cart_repository.add_item(
        db, cart_id=cart.id, product_id=data.product_id, quantity=data.quantity
    )
    return {"message": "Produk ditambahkan ke keranjang.", "item_id": str(item.id)}


@router.patch(
    "/items/{item_id}",
    summary="Update Jumlah Item",
)
async def update_cart_item(
    item_id: str,
    data: CartItemUpdate,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Update jumlah produk di keranjang."""
    try:
        iid = uuid.UUID(item_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID item tidak valid.")

    item = await cart_repository.get_cart_item_by_id(db, item_id=iid)
    if not item:
        raise HTTPException(status_code=404, detail="Item tidak ditemukan.")

    # Validate ownership via cart
    cart = await cart_repository.get_cart_with_items(db, user_id=current_user.id)
    if not cart or item.cart_id != cart.id:
        raise HTTPException(status_code=403, detail="Akses ditolak.")

    product = await product_repository.get_by_id(db, product_id=item.product_id)
    available = float(product.stock_remaining) - float(product.stock_reserved) if product else 0
    if not product or product.status.value != "aktif" or available < data.quantity:
        raise HTTPException(422, detail=f"Stok tidak mencukupi. Tersedia: {available} kg")

    item = await cart_repository.update_item_quantity(db, item=item, quantity=data.quantity)
    return {"message": "Jumlah item diperbarui.", "quantity": float(item.quantity)}


@router.delete(
    "/items/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Hapus Item dari Keranjang",
)
async def remove_cart_item(
    item_id: str,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    """Hapus produk dari keranjang."""
    try:
        iid = uuid.UUID(item_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID item tidak valid.")

    item = await cart_repository.get_cart_item_by_id(db, item_id=iid)
    if not item:
        raise HTTPException(status_code=404, detail="Item tidak ditemukan.")

    cart = await cart_repository.get_cart_with_items(db, user_id=current_user.id)
    if not cart or item.cart_id != cart.id:
        raise HTTPException(status_code=403, detail="Akses ditolak.")

    await cart_repository.remove_item(db, item=item)
