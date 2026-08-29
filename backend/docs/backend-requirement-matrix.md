# Matriks PRD/SRS ke Backend

| Area | Endpoint/komponen utama | Bukti test |
|---|---|---|
| Auth dan sesi | `/auth/register`, OTP, login, refresh rotation, reset | unit security; E2E smoke |
| Verifikasi role | `/profile/verifications`, `/admin/verifications`, role switch | E2E smoke; authorization guards |
| Offer dan pembayaran Petani | `/offers`, `/payments`, `PaymentFlow` | E2E smoke settlement; idempotent state machine |
| Stock dan produk | `/stock`, `/products`, allocation table | E2E smoke; DB constraints |
| Cart dan checkout | `/cart`, `/orders/checkout`, checkout group/reservation | schema tests; E2E smoke; row locks |
| Payment/refund | `/payments`, webhook, demo transition | signature/status checks; retry attempt IDs; refund reversal |
| Shipping | `/shipping/*`, `/shipments/*` | fake-provider E2E smoke; polling task |
| Review/dispute | `/reviews`, `/disputes`, `/admin/disputes` | ownership/status checks |
| Ledger/payout/dashboard | `/ledger`, `/payouts`, `/dashboards/*` | balanced posting guard; immutable DB trigger |
| Notification | `/notifications`, `/devices`, Celery outbox delivery | retry-limited worker task |
| Harga/ML | `/prices/*`, `/admin/ml/*` | synthetic training integration test |
| Admin/audit | `/admin/users`, verification/dispute/ML groups, `audit_logs` | OpenAPI contract test |
| Deployment | migration-once, API, worker, beat, Caddy, backup/restore | Compose config and Docker build |

`tests/test_core.py` memeriksa keamanan data sensitif, validasi checkout, private-path traversal, dan keberadaan kelompok endpoint. `tests/test_pricing_integration.py` memeriksa seed → training → activation → prediction terhadap PostgreSQL nyata.
