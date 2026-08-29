# Runbook Prototype

## Deploy

1. Salin `.env.example` ke `.env`; isi secret unik, password database, domain, dan origin HTTPS.
2. Pilih semua provider secara eksplisit. Untuk demo tanpa bank gunakan `PAYMENT_PROVIDER=fake`.
3. Validasi konfigurasi: `docker compose -f docker-compose.prod.yml config`.
4. Jalankan: `docker compose -f docker-compose.prod.yml up -d --build`.
5. Pastikan migration job exit 0 dan `https://$DOMAIN/health` mengembalikan database/Redis `up`.
6. Bootstrap admin sekali melalui container API dengan environment admin sementara; hapus environment tersebut sesudahnya.

PostgreSQL dan Redis tidak mempublikasikan port pada compose production. Hanya Caddy membuka 80/443. KTP lokal berada pada volume privat yang tidak dipasang sebagai static route.

## Backup dan restore

Export `POSTGRES_USER` dan `POSTGRES_DB`, kemudian jalankan `scripts/backup.sh`. Uji restore secara berkala pada environment non-production dengan `scripts/restore.sh <dump>`; restore bersifat destruktif terhadap database target.

## Rollback

1. Ambil backup.
2. Kembalikan image/tag aplikasi sebelumnya.
3. Jalankan `alembic downgrade <revision-sebelumnya>` hanya setelah memastikan perubahan data kompatibel.
4. Restart API/worker/scheduler dan periksa health serta antrean Redis.

## Operasional

- Caddy menulis access log JSON dengan rotasi.
- Beat melepas reservation kedaluwarsa, mengirim notification outbox, dan memperbarui tracking.
- Notification gagal dicoba maksimal lima kali; record dengan `last_error` menjadi dead-letter operasional.
- Artifact ML dan media harus ikut strategi backup volume; fixture sintetis tidak boleh dipresentasikan sebagai data pasar nyata.
- Endpoint payment demo tidak boleh aktif pada `APP_ENV=production`.
