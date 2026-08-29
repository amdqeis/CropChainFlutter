# CropChain 🌾🔗

**CropChain** adalah aplikasi mobile berbasis 3 role pengguna (**Petani, Distributor, dan Pembeli**) yang mendigitalisasi alur distribusi hasil pertanian secara berjenjang. Backend prototype memakai payment gateway fake secara default; Midtrans sandbox tersedia sebagai adapter opsional dan tidak ada transfer bank nyata.

---

## 🚀 Fitur Utama & Alur Bisnis
```
PETANI  --(offer hasil panen)-->  DISTRIBUTOR  --(produk marketplace)-->  PEMBELI
```
1. **Petani**: Mengajukan tawaran (*offer*) hasil panen (jenis, estimasi jumlah, harga usulan, lokasi, estimasi panen).
2. **Distributor**: Menerima/menyeleksi penawaran petani, membayar hasil panen melalui gateway prototype, mengonsolidasi stok, dan membuat listing penjualan baru untuk pembeli.
3. **Pembeli**: Berbelanja hasil tani dengan mode **Retail** (eceran) atau **Grosir** (skala besar dengan harga tier khusus), serta melakukan pembayaran via Midtrans Snap/Core API.

---

## 🛠️ Tech Stack

### Backend
* **Framework**: FastAPI (Python 3.11+)
* **Database**: PostgreSQL (driver `asyncpg`)
* **Caching & Queue**: Redis
* **ORM & Migrations**: SQLAlchemy & Alembic
* **Payment Gateway**: fake deterministik (default) atau Midtrans sandbox

### Frontend (Mobile)
* **Framework**: Flutter (Dart)
* **State Management**: Flutter Riverpod
* **Routing**: GoRouter (mendukung *role-based routing*)
* **HTTP Client**: Dio (dengan interceptor untuk JWT)
* **Local Storage**: Flutter Secure Storage (untuk token JWT)

---

## 📦 Struktur Project
```
IISIEC/
├── backend/          # Kode sumber FastAPI Backend
│   ├── app/          # Core logic, models, schemas, api, services
│   ├── Dockerfile    # Docker build backend
│   └── docker-compose.yml
└── frontend/         # Kode sumber Flutter Mobile App
    ├── lib/          # Core, features, presentation, providers
    └── pubspec.yaml  # Dependency Flutter
```

---

## 🖥️ Cara Menjalankan Backend (FastAPI)

Terdapat 2 metode untuk menjalankan backend API:

### Metode 1: Menggunakan Docker Compose (Sangat Direkomendasikan 🐳)
Metode ini adalah cara tercepat karena akan otomatis mengonfigurasi FastAPI, PostgreSQL, dan Redis secara kontainerisasi.

1. **Jalankan Docker Compose**:
   Pastikan Docker Desktop / Docker Engine Anda sudah aktif, lalu jalankan perintah berikut di root folder `backend`:
   ```bash
   cd backend
   docker compose up --build
   ```
2. **Akses API & Dokumentasi**:
   * **API Base URL**: `http://localhost:8000`
   * **Interactive Swagger UI**: `http://localhost:8000/docs`
   * **ReDoc (Alternative Docs)**: `http://localhost:8000/redoc`

---

### Metode 2: Setup Lokal Manual (Tanpa Docker)
Jika ingin menjalankan backend secara langsung di sistem lokal Anda:

1. **Prasyarat**:
   * Instal **Python 3.11+**
   * Instal **PostgreSQL** dan jalankan layanannya.
   * Instal **Redis Server** dan jalankan layanannya.

2. **Buat Database**:
   Masuk ke database PostgreSQL Anda dan buat database kosong baru dengan nama `cropchain`:
   ```sql
   CREATE DATABASE cropchain;
   ```

3. **Konfigurasi Environment**:
   * Masuk ke folder `backend`:
     ```bash
     cd backend
     ```
   * Salin file `.env.example` menjadi `.env`:
     ```bash
     cp .env.example .env
     ```
   * Buka `.env` dan sesuaikan kredensial PostgreSQL (`DATABASE_URL`) serta Redis (`REDIS_URL`) sesuai konfigurasi lokal Anda.

4. **Setup Virtual Environment & Install Dependencies**:
   * Buat virtual environment Python:
     ```bash
     python -m venv venv
     ```
   * Aktifkan virtual environment:
     * **Linux / macOS**: `source venv/bin/activate`
     * **Windows (Command Prompt)**: `venv\Scripts\activate.bat`
     * **Windows (PowerShell)**: `venv\Scripts\Activate.ps1`
   * Instal seluruh dependencies:
     ```bash
     pip install -r requirements.txt
     ```

5. **Migrasi Database**:
   Migrasi sudah tersedia dan tidak perlu diinisialisasi ulang:
   ```bash
   alembic upgrade head
   ```

6. **Jalankan Backend**:
   Jalankan server pengembangan Uvicorn:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   Server Anda sekarang berjalan di `http://localhost:8000`.

---

## 📱 Cara Menjalankan Frontend (Flutter)

Aplikasi frontend berjalan menggunakan Flutter SDK.

1. **Prasyarat**:
   * Instal **Flutter SDK** (versi stable terbaru direkomendasikan).
   * Pastikan emulator Android, iOS Simulator, atau perangkat fisik (USB Debugging) terhubung dan dikenali oleh Flutter (`flutter devices`).

2. **Masuk ke folder frontend**:
   ```bash
   cd frontend
   ```

3. **Instal Dependensi**:
   Unduh dependensi pubspec:
   ```bash
   flutter pub get
   ```

4. **Jalankan Generator (Jika dibutuhkan di masa depan)**:
   Proyek ini menyertakan `riverpod_generator`. Jika nanti Anda menambahkan anotasi generator Riverpod, buat file autogenerasi dengan:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Konfigurasikan URL API (Wajib)**:
   Berikan origin backend tanpa akhiran `/api/v1` melalui `--dart-define`.
   Contoh Android emulator: `http://10.0.2.2:8000`; iOS Simulator:
   `http://localhost:8000`; perangkat fisik memakai IP/HTTPS backend yang dapat
   dijangkau perangkat.

6. **Jalankan Aplikasi**:
   ```bash
   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8000
   ```
   Pilih emulator atau perangkat target yang ingin Anda gunakan untuk menjalankan CropChain.

---

## 🧪 Menjalankan Unit Test

### Backend
Untuk menjalankan testing pada FastAPI backend, gunakan `pytest`:
```bash
cd backend
pytest
```
# CropChainFlutter
