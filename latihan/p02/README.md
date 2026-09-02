# Latihan Manajemen Sistem Basis Data 2

**Kelompok**: Kelompok 3  
**Domain Sistem**: Sistem Informasi Pelayanan dan Manajemen Klinik Kampus

**Nama Anggota:**
- Tabhita Kristy SIlitonga - 251402023 (PM)
- Jevine Jeje Zakarias Simanjuntak - 251402085
- Fadila Lisma Sari - 251402117
- Qairsya Naurel ein Yaliki - 251402120
- Reynald Alvaro Pasaribu - 251402147

---

## Panduan Menjalankan Sistem

### 1. Menjalankan Docker Compose
Jalankan seluruh service container (PostgreSQL, Flyway, MongoDB, Redis) di latar belakang:
```bash
docker compose up -d
```
Pastikan container database berjalan normal
```bash
docker compose ps
```

---

### 2. Menjalankan Database Migration (Flyway)
Eksekusi seluruh file migrasi skema (V1 sampai V5) ke dalam database proyek_dev:
```bash
docker compose run --rm flyway migrate
```
Untuk memverifikasi status versi dan riwayat skema yang telah diterapkan:
```bash
docker compose run --rm flyway info
```

---

### 3. Menjalankan Seed Data (Idempoten)
Masukkan data awal master peran dan referensi ke dalam basis data:
```bash
docker compose exec -T postgres psql -U msbd -d proyek_dev < latihan/p02/seeds/01_peran.sql
```
Skrip seeder dirancang bersifat idempoten (ON CONFLICT DO NOTHING), sehingga aman dijalankan berulang kali tanpa memicu duplikasi data atau error unique constraint.