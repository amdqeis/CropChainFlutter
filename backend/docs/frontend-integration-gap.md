# Frontend Integration Gap

Frontend Flutter tidak diubah dalam pekerjaan backend ini. Integrasi berikut perlu diselaraskan oleh pekerjaan frontend terpisah:

- istilah role lama `tengkulak` harus menjadi `distributor`;
- mock authentication harus diganti dengan register → OTP → token pair dan refresh rotation;
- checkout lama satu produk perlu memakai payload buy-now/cart multi-item, address, shipping-rate per distributor, payment method, dan idempotency key;
- order baru dimulai pada `menunggu_pembayaran`, bukan langsung `diproses`;
- pembayaran demo menggunakan redirect/token pada response checkout dan simulasi settlement hanya untuk environment development;
- KTP harus diunggah ke `/uploads/ktp`; client menyimpan `private_asset`, bukan URL media publik;
- UI perlu menangani list order per distributor, shipment per order, notification, dispute, dashboard, dan prediksi 7/30 hari.
- pembayaran hasil penerimaan Offer dapat dicari melalui endpoint status pembayaran
  yang sama dengan menggunakan `offer_id`, tanpa perubahan bentuk response.

Prefix tetap `/api/v1`. Route `/products/distributor/me` sudah aman dari konflik dynamic product UUID.
