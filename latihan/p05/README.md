# Panduan singkat untuk setup database, menjalankan program Python, dan ngetes API praktikum modul 5

## Prasyarat

* Docker & Docker Compose sudah jalan (kontainer PostgreSQL aktif).
* Python 3.11+ dan virtual environment aktif (.venv).
* Package terpasang:
```bash
pip install "psycopg[binary,pool]>=3.2" "sqlalchemy>=2.0" "fastapi>=0.115" "uvicorn>=0.32" "pydantic>=2.0"
```

---

## Variabel DSN

Aplikasi memakai format koneksi DSN berikut:
```bash
DSN="postgresql://msbd:msbd2026@127.0.0.1:5432/latihan"
```
Kalau mau set lewat environment variable di terminal:
```bash
export DSN="postgresql://msbd:msbd2026@127.0.0.1:5432/latihan"
```

---

## Cara setup lab5

Eksekusi file setup awal ke kontainer docker:
```bash
docker compose exec -T postgres psql -U msbd -d latihan -f /dev/stdin < latihan/p05/q00_setup.sql
```
Jalankan juga procedure rental:
```bash
docker compose exec -T postgres psql -U msbd -d latihan -f /dev/stdin < latihan/p05/q02_process_rental.sql
```

---

## Cara Menjalankan Program Python

Pastikan virtual environment sudah nyala:
* Windows (Git Bash): source .venv/Scripts/activate
* Linux / Mac: source .venv/bin/activate

**A. Driver psycopg (lab5_driver.py)**
Menjalankan tes query parameter, rollback transaksi, connection pool, dan idle in transaction:
```bash
python latihan/p05/lab5_driver.py
```
**B. SQLAlchemy ORM (lab5_orm.py)**
Menjalankan pembuktian masalah query N+1 serta solusinya pakai selectinload dan joinedload:
```bash
python latihan/p05/lab5_orm.py
```
**C. REST API FastAPI (lab5_api.py)**
Jalankan server lokal pakai uvicorn:
```bash
uvicorn latihan.p05.lab5_api:app --reload --port 8000
```
Dokumentasi Swagger UI otomatis bisa dibuka di browser: `http://127.0.0.1:8000/docs`

---

## Uji Coba Endpoint via curl (Q22–Q24)

Buka tab terminal baru saat server FastAPI sedang running:
**Q22 - Buat rental baru (POST /rentals)**
```bash
curl -X POST http://127.0.0.1:8000/rentals \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": 1,
    "inventory_id": 1,
    "staff_id": 1,
    "amount": 4.99,
    "tags": ["sci-fi", "favorite"],
    "metadata": {"source": "web_mobile"}
  }'
```
**Q23 - Ambil daftar rental + filter & pagination (GET /rentals)**
```bash
curl -X GET "http://127.0.0.1:8000/rentals?status_filter=ACTIVE&limit=5&offset=0"
```
**Q24 - Update status rental (PATCH /rentals/{rental_id}/status)**
```bash
curl -X PATCH http://127.0.0.1:8000/rentals/1/status \
  -H "Content-Type: application/json" \
  -d '{
    "status": "RETURNED"
  }'
```