# Latihan Kelompok Pertemuan 11

## Prasyarat dan Setup Kontainer
Seluruh percobaan pada repositori ini dikerjakan di dalam kontainer yang tidak terhubung ke internet.
Bukti jaringan tertutup: `docker network inspect lab11_labnet --format '{{.Internal}}'` (Hasil: `true`).

**Cara Menyalakan Dua Kontainer:**
1. Masuk ke direktori yang berisi konfigurasi docker.
2. Jalankan perintah: `docker compose -f docker-compose.lab11.yml up -d`

**Cara Memuat Skema lab11:**
1. Salin skrip ke kontainer: `docker cp sql/lab11_setup.sql lab11-db:/sql/lab11_setup.sql`
2. Eksekusi skrip: `docker exec -i lab11-db psql -U postgres -d msbd -f /sql/lab11_setup.sql`

## Urutan Menjalankan Q1-Q30
Skrip SQL disusun agar dijalankan secara berurutan karena state saling bergantung.
- **Langkah 2 (Kepemilikan & Peran):** Jalankan `q01` hingga `q05` sebagai superuser.
- **Langkah 3 (RLS):** Jalankan `q06` hingga `q11` (gunakan koneksi `app_laporan` untuk pengujian).
- **Langkah 4 (Injeksi):** Eksekusi `rentan.py` dari kontainer `lab11-web`, lalu jalankan `q12` hingga `q18`.
- **Langkah 5 (Enkripsi & Hashing):** Jalankan `q19` hingga `q24`.
- **Langkah 6 (Audit & UU PDP):** Jalankan `q25` hingga `q29`. Pemetaan Q30 dapat dilihat di file `laporan.md`.

