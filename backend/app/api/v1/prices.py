"""Price history, prediction, and admin ML operations."""
import csv
import io
import uuid
from datetime import date

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db_session, require_admin
from app.models.pricing import MarketPriceObservation
from app.models.user import User
from app.schemas.operations import PriceObservationInput, PricePredictionResponse
from app.services.pricing_service import pricing_service

router = APIRouter()
admin_router = APIRouter()


@router.get("/history")
async def price_history(
    commodity: str, district: str, limit: int = Query(90, ge=1, le=365),
    db: AsyncSession = Depends(get_db_session),
):
    result = await db.execute(select(MarketPriceObservation).where(
        MarketPriceObservation.commodity == commodity.strip().lower(),
        MarketPriceObservation.district == district.strip().lower(),
    ).order_by(MarketPriceObservation.observed_at.desc()).limit(limit))
    return [{"observed_at": row.observed_at, "price_per_kg": float(row.price_per_kg), "source": row.source, "is_synthetic": row.is_synthetic} for row in result.scalars()]


@router.get("/predict", response_model=PricePredictionResponse)
async def predict_price(commodity: str, district: str, horizon_days: int = Query(7), db: AsyncSession = Depends(get_db_session)):
    try:
        return await pricing_service.predict(db, commodity=commodity, district=district, horizon_days=horizon_days)
    except ValueError as exc:
        raise HTTPException(422, str(exc)) from exc


@admin_router.post("/observations/import")
async def import_csv(file: UploadFile = File(...), db: AsyncSession = Depends(get_db_session), _: User = Depends(require_admin)):
    if file.content_type not in {"text/csv", "application/vnd.ms-excel", "application/octet-stream"}:
        raise HTTPException(422, "File harus CSV.")
    content = (await file.read()).decode("utf-8-sig")
    reader = csv.DictReader(io.StringIO(content))
    required = {"observed_at", "commodity", "district", "price_per_kg", "source"}
    if not reader.fieldnames or not required.issubset(reader.fieldnames):
        raise HTTPException(422, f"Kolom wajib: {', '.join(sorted(required))}")
    rows = []
    try:
        for raw in reader:
            rows.append(PriceObservationInput(
                observed_at=date.fromisoformat(raw["observed_at"]), commodity=raw["commodity"],
                district=raw["district"], price_per_kg=float(raw["price_per_kg"]), source=raw["source"],
                volume_kg=float(raw["volume_kg"]) if raw.get("volume_kg") else None,
                is_synthetic=raw.get("is_synthetic", "false").lower() == "true",
            ))
    except (ValueError, TypeError) as exc:
        raise HTTPException(422, f"CSV tidak valid: {exc}") from exc
    return await pricing_service.import_rows(db, rows)


@admin_router.post("/seed-demo")
async def seed_demo(db: AsyncSession = Depends(get_db_session), _: User = Depends(require_admin)):
    return await pricing_service.seed_demo(db)


@admin_router.post("/train")
async def train_model(db: AsyncSession = Depends(get_db_session), _: User = Depends(require_admin)):
    run = await pricing_service.train(db)
    return {"run_id": str(run.id), "status": run.status.value, "metrics": run.metrics, "error": run.error, "model_version_id": str(run.model_version_id) if run.model_version_id else None}


@admin_router.post("/models/{model_id}/activate")
async def activate_model(model_id: uuid.UUID, db: AsyncSession = Depends(get_db_session), _: User = Depends(require_admin)):
    try:
        model = await pricing_service.activate(db, model_id)
        return {"id": str(model.id), "version": model.version, "active": model.is_active}
    except ValueError as exc:
        raise HTTPException(409, str(exc)) from exc
