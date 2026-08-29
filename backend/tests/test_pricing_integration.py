import os

import pytest
from sqlalchemy import delete

from app.core.database import AsyncSessionLocal
from app.models.pricing import MarketPriceObservation, ModelVersion, PricePrediction, TrainingRun, TrainingStatus
from app.services.pricing_service import pricing_service


@pytest.mark.integration
@pytest.mark.skipif(not os.getenv("RUN_INTEGRATION_TESTS"), reason="set RUN_INTEGRATION_TESTS=1")
async def test_synthetic_training_activation_and_prediction():
    async with AsyncSessionLocal() as db:
        await db.execute(delete(PricePrediction))
        await db.execute(delete(TrainingRun))
        await db.execute(delete(ModelVersion))
        await db.execute(delete(MarketPriceObservation))
        await db.commit()

        seeded = await pricing_service.seed_demo(db)
        assert seeded["inserted"] >= 500
        run = await pricing_service.train(db)
        assert run.status == TrainingStatus.SUCCEEDED, run.error
        assert run.model_version_id

        model = await pricing_service.activate(db, run.model_version_id)
        assert model.is_active
        prediction = await pricing_service.predict(
            db, commodity="cabai merah", district="sumedang", horizon_days=7
        )
        assert prediction.predicted_price_per_kg > 0
        assert not prediction.is_baseline
