# Laporan P04 — SQL Lanjutan II
## Materialized View: Q5–Q8 dan Reflektif B

## Q5 — Query Dasar Akses

Query dasar digunakan untuk merangkum data `lab4.jejak_akses` berdasarkan bulan dan kanal. Query menghitung jumlah akses dan jumlah film unik.

Hasil query mencakup data dari September 2025 sampai Maret 2026 untuk kanal `android`, `ios`, `kiosk`, dan `web`.

### Timing

- Q5 Query dasar: **[ISI ANGKA TIME Q5 DI SINI]**

## Q6 — Membuat Materialized View

Materialized view dibuat dengan nama `lab4.ringkasan_akses` menggunakan `WITH NO DATA`.

### Error sebelum refresh

```text
ERROR:  materialized view "ringkasan_akses" has not been populated
HINT:  Use the REFRESH MATERIALIZED VIEW command

