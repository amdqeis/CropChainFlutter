"""Prototype price ingestion, training, and inference."""
import math
import uuid
from datetime import date, datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.pricing import MarketPriceObservation, ModelVersion, PricePrediction, TrainingRun, TrainingStatus
from app.schemas.operations import PriceObservationInput


class PricingService:
    async def import_rows(self, db: AsyncSession, rows: list[PriceObservationInput]) -> dict:
        inserted = skipped = 0
        for row in rows:
            exists = await db.scalar(select(MarketPriceObservation.id).where(
                MarketPriceObservation.observed_at == row.observed_at,
                MarketPriceObservation.commodity == row.commodity.strip().lower(),
                MarketPriceObservation.district == row.district.strip().lower(),
                MarketPriceObservation.source == row.source.strip(),
            ))
            if exists:
                skipped += 1
                continue
            db.add(MarketPriceObservation(
                observed_at=row.observed_at, commodity=row.commodity.strip().lower(),
                district=row.district.strip().lower(), price_per_kg=row.price_per_kg,
                source=row.source.strip(), volume_kg=row.volume_kg, is_synthetic=row.is_synthetic,
            ))
            inserted += 1
        await db.commit()
        return {"inserted": inserted, "skipped": skipped}

    async def seed_demo(self, db: AsyncSession) -> dict:
        rows = []
        start = date.today() - timedelta(days=180)
        for commodity, base in (("cabai merah", 42000), ("tomat", 11000), ("beras", 14500)):
            for day in range(181):
                trend = day * (25 if commodity == "cabai merah" else 4)
                seasonal = math.sin(day / 14) * base * 0.08
                rows.append(PriceObservationInput(
                    observed_at=start + timedelta(days=day), commodity=commodity,
                    district="sumedang", price_per_kg=round(base + trend + seasonal, 2),
                    source="fixture-synthetic", is_synthetic=True,
                ))
        return await self.import_rows(db, rows)

    async def train(self, db: AsyncSession) -> TrainingRun:
        run = TrainingRun(status=TrainingStatus.RUNNING, started_at=datetime.now(timezone.utc), metrics={})
        db.add(run)
        await db.commit()
        try:
            result = await db.execute(select(MarketPriceObservation).order_by(MarketPriceObservation.observed_at))
            rows = list(result.scalars())
            if len(rows) < 60:
                raise ValueError("Minimal 60 observasi diperlukan untuk training prototype.")
            commodities = {value: index for index, value in enumerate(sorted({r.commodity for r in rows}))}
            districts = {value: index for index, value in enumerate(sorted({r.district for r in rows}))}
            features = [[r.observed_at.toordinal(), commodities[r.commodity], districts[r.district]] for r in rows]
            targets = [float(r.price_per_kg) for r in rows]
            split = max(1, int(len(rows) * 0.8))
            baseline = sum(targets[:split]) / split
            baseline_mae = sum(abs(value - baseline) for value in targets[split:]) / max(1, len(targets[split:]))
            from sklearn.ensemble import HistGradientBoostingRegressor
            from sklearn.metrics import mean_absolute_error, mean_absolute_percentage_error
            import joblib
            model = HistGradientBoostingRegressor(max_depth=5, learning_rate=0.08, random_state=42)
            model.fit(features[:split], targets[:split])
            predicted = model.predict(features[split:])
            mae = float(mean_absolute_error(targets[split:], predicted))
            mape = float(mean_absolute_percentage_error(targets[split:], predicted))
            artifact_dir = Path(settings.UPLOAD_DIR) / "models"
            artifact_dir.mkdir(parents=True, exist_ok=True)
            version = f"price-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}-{uuid.uuid4().hex[:6]}"
            artifact = artifact_dir / f"{version}.joblib"
            joblib.dump(model, artifact)
            metrics = {"mae": mae, "mape": mape, "baseline_mae": baseline_mae, "beats_baseline": mae < baseline_mae, "observations": len(rows)}
            model_version = ModelVersion(
                version=version, algorithm="HistGradientBoostingRegressor",
                artifact_path=str(artifact), metrics=metrics,
                feature_schema={"commodities": commodities, "districts": districts},
                is_active=False,
            )
            db.add(model_version)
            await db.flush()
            run.status = TrainingStatus.SUCCEEDED
            run.model_version_id = model_version.id
            run.metrics = metrics
            run.finished_at = datetime.now(timezone.utc)
        except Exception as exc:
            run.status = TrainingStatus.FAILED
            run.error = str(exc)
            run.finished_at = datetime.now(timezone.utc)
        await db.commit()
        await db.refresh(run)
        return run

    async def activate(self, db: AsyncSession, model_id: uuid.UUID) -> ModelVersion:
        model = await db.get(ModelVersion, model_id)
        if not model:
            raise ValueError("Model tidak ditemukan.")
        if not model.metrics.get("beats_baseline"):
            raise ValueError("Model tidak mengalahkan baseline dan tidak boleh diaktifkan.")
        await db.execute(update(ModelVersion).values(is_active=False))
        model.is_active = True
        await db.commit()
        await db.refresh(model)
        return model

    async def predict(self, db: AsyncSession, *, commodity: str, district: str, horizon_days: int) -> PricePrediction:
        if horizon_days not in {7, 30}:
            raise ValueError("Horizon hanya 7 atau 30 hari.")
        commodity = commodity.strip().lower()
        district = district.strip().lower()
        model = await db.scalar(select(ModelVersion).where(ModelVersion.is_active.is_(True)).order_by(ModelVersion.created_at.desc()))
        is_baseline = True
        version = "rolling-median-baseline"
        observations = await db.execute(select(MarketPriceObservation.price_per_kg).where(
            MarketPriceObservation.commodity == commodity,
            MarketPriceObservation.district == district,
        ).order_by(MarketPriceObservation.observed_at.desc()).limit(30))
        values = [float(value) for value in observations.scalars()]
        if not values:
            raise ValueError("Data harga untuk komoditas/wilayah belum tersedia.")
        predicted = sorted(values)[len(values) // 2]
        if model:
            schema = model.feature_schema
            if commodity in schema["commodities"] and district in schema["districts"]:
                import joblib
                estimator = joblib.load(model.artifact_path)
                predicted = float(estimator.predict([[date.today().toordinal() + horizon_days, schema["commodities"][commodity], schema["districts"][district]]])[0])
                version = model.version
                is_baseline = False
        prediction = PricePrediction(
            model_version=version, commodity=commodity, district=district,
            horizon_days=horizon_days, predicted_for=date.today() + timedelta(days=horizon_days),
            predicted_price_per_kg=Decimal(str(round(predicted, 2))),
            lower_bound=Decimal(str(round(predicted * 0.85, 2))),
            upper_bound=Decimal(str(round(predicted * 1.15, 2))), is_baseline=is_baseline,
        )
        db.add(prediction)
        await db.commit()
        await db.refresh(prediction)
        return prediction


pricing_service = PricingService()
