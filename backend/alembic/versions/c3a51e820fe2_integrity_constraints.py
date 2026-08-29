"""Add integrity constraints for commerce, accounting, and ML data.

Revision ID: c3a51e820fe2
Revises: b1f9cea001f6
"""
from typing import Sequence, Union

from alembic import op


revision: str = "c3a51e820fe2"
down_revision: Union[str, None] = "b1f9cea001f6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


CHECKS = {
    "stock": {
        "ck_stock_quantity_nonnegative": "quantity_available >= 0",
        "ck_stock_reserved_valid": "quantity_reserved >= 0 AND quantity_reserved <= quantity_available",
    },
    "products": {
        "ck_products_stock_nonnegative": "stock_remaining >= 0",
        "ck_products_reserved_valid": "stock_reserved >= 0 AND stock_reserved <= stock_remaining",
        "ck_products_prices_positive": "public_price > 0 AND wholesale_price > 0",
    },
    "payments": {"ck_payments_amount_positive": "amount > 0"},
    "order_items": {
        "ck_order_items_quantity_positive": "quantity > 0",
        "ck_order_items_amounts_nonnegative": "unit_price >= 0 AND subtotal >= 0",
    },
    "product_stock_allocations": {
        "ck_allocations_quantity_positive": "allocated_quantity > 0",
        "ck_allocations_consumed_valid": "consumed_quantity >= 0 AND consumed_quantity <= allocated_quantity",
    },
    "inventory_reservations": {"ck_reservations_quantity_positive": "quantity > 0"},
    "shipments": {"ck_shipments_fee_nonnegative": "fee >= 0"},
    "payouts": {"ck_payouts_amount_positive": "amount > 0"},
    "market_price_observations": {"ck_observation_price_positive": "price_per_kg > 0"},
    "price_predictions": {
        "ck_prediction_horizon": "horizon_days IN (7, 30)",
        "ck_prediction_bounds": "lower_bound <= predicted_price_per_kg AND predicted_price_per_kg <= upper_bound",
    },
}


def upgrade() -> None:
    for table, constraints in CHECKS.items():
        for name, expression in constraints.items():
            op.create_check_constraint(name, table, expression)
    op.create_foreign_key(
        "fk_training_runs_model_version_id",
        "training_runs",
        "model_versions",
        ["model_version_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.execute(
        "CREATE UNIQUE INDEX uq_active_dispute_per_order ON disputes (order_id) "
        "WHERE status IN ('open', 'in_review')"
    )
    op.execute(
        """
        CREATE FUNCTION prevent_ledger_mutation() RETURNS trigger AS $$
        BEGIN
            RAISE EXCEPTION 'ledger records are immutable';
        END;
        $$ LANGUAGE plpgsql
        """
    )
    for table in ("ledger_transactions", "ledger_entries"):
        op.execute(
            f"CREATE TRIGGER trg_{table}_immutable BEFORE UPDATE OR DELETE ON {table} "
            "FOR EACH ROW EXECUTE FUNCTION prevent_ledger_mutation()"
        )


def downgrade() -> None:
    for table in ("ledger_transactions", "ledger_entries"):
        op.execute(f"DROP TRIGGER IF EXISTS trg_{table}_immutable ON {table}")
    op.execute("DROP FUNCTION IF EXISTS prevent_ledger_mutation()")
    op.execute("DROP INDEX IF EXISTS uq_active_dispute_per_order")
    op.drop_constraint("fk_training_runs_model_version_id", "training_runs", type_="foreignkey")
    for table, constraints in reversed(list(CHECKS.items())):
        for name in constraints:
            op.drop_constraint(name, table, type_="check")
