# Panduan Eksekusi SQL Lanjutan II (P04)

Dokumentasi teknis untuk menjalankan seluruh rangkaian skrip SQL dari `q00_setup.sql` hingga `q21_migrasi_berversi.md` pada lingkungan PostgreSQL di Docker.

---

## Prasyarat Lingkungan

* Docker & Docker Compose sudah aktif.
* Container layanan database `postgres` berjalan normal.
* Skema kerja menggunakan schema `lab4` dan role `msbd` pada basis data `latihan`.
* Ekstensi `btree_gist` didukung pada server database.

---

## Inisialisasi Setup Awal (q00_setup.sql)

Sebelum menjalankan pengujian, siapkan seluruh tabel sampel dan data awal dengan mengeksekusi `q00_setup.sql` langsung melalui terminal:

```bash
docker compose exec -T postgres psql -U msbd -d latihan < latihan/p04/q00_setup.sql
```

Jika data dasar tabel film belum tersedia dari basis data publik, pastikan tabel lab4.film terisi minimal 1.000 baris data uji.

---

## Urutan Q1-Q21
### Views & Updateable Views
- `01_view_film_murah.sql` Pembuatan updatable view sederhana
- `q02_baris_menghilang.sql` Demonstrasi anomali data hilang akibat pembaruan nilai di luar kriteria view
- `q03_check_option.sql` Penerapan WITH CASCADED CHECK OPTION untuk validasi baris pada view

### Materialized Views & Refresh Performance
- `q04_view_pendapatan_kategori.sql` Agregasi data kategori pendapatan
- `q05_query_dasar_akses.sql` Pengukuran waktu baca dasar tabel log transaksi fisik
- `q06_buat_matview.sql` Pembuatan materialized view dengan opsi WITH NO DATA dan refresh pertama
- `q07_refresh_concurrently.sql` Refresh konkuren tanpa mengunci pembaca (read-access)
- `q08_buktikan_pembacaan.sql` Pembuktian akses pembacaan tidak terblokir selama proses refresh konkuren

### Trigger & Data Auditing
- `q09_trigger_audit_baris.sql` Pembuatan fungsi PL/pgSQL dan trigger audit tingkat baris (ROW)
- `q10_uji_audit_baris.sql` Verifikasi pencatatan audit perubahan data
- `q11_null_pada_trigger.sql` Analisis operator <> vs IS DISTINCT FROM terhadap nilai NULL.
- `q12_biaya_trigger_baris.sql` Pengukuran durasi pembaruan massal saat trigger baris aktif vs nonaktif
- `q13_trigger_pernyataan.sql` Optimalisasi audit menggunakan trigger tingkat pernyataan (STATEMENT) dan tabel transisi

### Constraints & Integrity Rules
- `q14_check_not_valid.sql` Validasi aturan CHECK secara bertahap tanpa exclusive lock panjang (NOT VALID).
- `q15_unique_soft_delete.sql` Parsial unique index untuk data aktif pada pola soft delete.
- `q16_fk_aksi_referensial.sql` Perbandingan aksi ON DELETE RESTRICT dan ON DELETE CASCADE.
- `q17_exclude_tumpangtindih.sql` Pencegahan bentrok rentang tanggal menggunakan exclusion constraint GIST.

### Zero-Downtime Migration Pattern (Expand-Contract)
- `q18_expand_tulis_ganda.sql` Tahap Expand: Pembuatan tabel partisi harga dan trigger sinkronisasi ganda
- `q19_backfill_bertahap.sql` Pengisian data historis ke skema target baru
- `q20_contract_view_fasad.sql` Tahap Contract: Penghapusan kolom lama dan pembuatan view fasad kompatibilitas
- `q21_migrasi_berversi.md` Verifikasi akhir transparansi data tanpa gangguan operasional sistem

---

## Dua Sesi pada Q8 & Q20
Beberapa tahap pengujian memerlukan dua jendela terminal psql aktif secara bersamaan untuk mereplikasi kondisi multi-transaksi (concurrency):
### Q8 (q08_buktikan_pembacaan.sql):
- Terminal 1: Menjalankan perintah `REFRESH MATERIALIZED VIEW CONCURRENTLY`
- Terminal 2: Menjalankan kueri SELECT ke materialized view pada saat bersamaan untuk membuktikan data tetap bisa dibaca secara real-time tanpa terkena kunci eksklusif (table lock).

### Q20 (q20_contract_view_fasad.sql):
- Terminal 1: Melakukan eksekusi DDL modifikasi struktur (`ALTER TABLE ... RENAME/DROP COLUMN`).
- Terminal 2: Mensimulasikan kueri transaksi aplikasi yang aktif membaca data guna memastikan transisi view fasad berjalan mulus.

---

## Peringatan Khusus
**Kerusakan Permanen Struktur Data (Q20 / 0046)**

Eksekusi perintah pada Q20 mencakup operasi `ALTER TABLE lab4.film_data DROP COLUMN rental_rate;`. Operasi penghapusan kolom fisik ini bersifat permanen dan tidak dapat dipulihkan secara penuh (irreversible) tanpa melakukan restore dari cadangan (backup). Pastikan tahap migrasi data historis (Q19) telah terverifikasi menghasilkan `count = 0` sebelum menjalankan tahap ini.