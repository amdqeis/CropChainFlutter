"""
Uploads Router — File upload endpoint for images (KTP, products, offers).
"""
import uuid
from typing import List

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from fastapi.responses import FileResponse, RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session
from app.core.storage import cloudinary_private_url, private_asset_path, save_upload_file, save_multiple_files
from app.models.role_verification import RoleVerification
from app.models.user import User

router = APIRouter()


@router.post(
    "/image",
    summary="Upload Satu Gambar",
)
async def upload_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_verified_user),
):
    """
    Upload satu gambar (JPEG/PNG/WebP, maksimum 5MB).
    Mengembalikan URL yang bisa dipakai sebagai nilai field `photo` atau `ktp_photo`.
    """
    try:
        url = await save_upload_file(file, subdir="images")
        return {"url": url, "filename": file.filename}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(e))


@router.post(
    "/images",
    summary="Upload Beberapa Gambar (Maks 5)",
)
async def upload_multiple_images(
    files: List[UploadFile] = File(...),
    current_user: User = Depends(get_current_verified_user),
):
    """
    Upload beberapa gambar sekaligus (maksimum 5 file).
    Mengembalikan array URL yang bisa dipakai sebagai nilai field `photo`.
    """
    try:
        urls = await save_multiple_files(files, subdir="images", max_files=5)
        return {"urls": urls, "count": len(urls)}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(e))


@router.post("/ktp", summary="Upload KTP Privat")
async def upload_ktp(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_verified_user),
):
    try:
        url = await save_upload_file(file, subdir="ktp", private=True)
        return {"private_asset": url}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(e))


@router.get("/private/verifications/{verification_id}", summary="Akses KTP Privat")
async def get_private_verification_asset(
    verification_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_verified_user),
):
    verification = await db.get(RoleVerification, verification_id)
    if not verification or (verification.user_id != current_user.id and not current_user.is_admin):
        raise HTTPException(status_code=404, detail="Aset tidak ditemukan.")
    try:
        if verification.ktp_photo.startswith("cloudinary://"):
            return RedirectResponse(cloudinary_private_url(verification.ktp_photo), status_code=307)
        path = private_asset_path(verification.ktp_photo)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    if not path.is_file():
        raise HTTPException(status_code=404, detail="Aset tidak ditemukan.")
    return FileResponse(path, media_type="image/jpeg", filename="ktp.jpg")
