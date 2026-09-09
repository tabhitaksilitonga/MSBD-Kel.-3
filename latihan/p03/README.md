# Latihan Pertemuan 3 - SQL Lanjutan I

---

## Prasyarat
- Docker Engine dan Docker Compose aktif.
- PostgreSQL 17.x berjalan pada kontainer Docker (servis `postgres` / `msbd-pg`).
- Basis data `pagila` telah terisi (tabel `film` minimal 1.000 baris dan tabel `payment` memiliki riwayat transaksi).

---

## Menjalankan Setup Tabel Bantu
Sebelum menjalankan kueri Q06–Q09 dan Q19–Q20, inisialisasi tabel bantu `pegawai` dan `notifikasi` terlebih dahulu dengan perintah:

```bash
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q00_setup.sql
```

---

## Menjalankan Jawaban Kueri (Q01 - Q20 & R1)
# Langkah 3: Subquery (Q01 - Q05)
```bash
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q01_tarif_di_atas_rata_rata.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q02_kategori_lebih_60.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q03_pelanggan_pembayaran_besar.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q04_film_tidak_pernah_disewa.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q05_tarif_tertinggi_per_toko.sql
```

# Langkah 4: CTE dan Recursive CTE (Q06 - Q09)
```bash
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q06_cte_kategori.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q07_hierarki_pegawai.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q08_bawahan_bima.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q09_rekursi_tahan_siklus.sql
```

# Langkah 5: Window Function (Q10 - Q15)
```bash
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q10_tiga_peringkat_tarif.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q11_tiga_film_tertinggi.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q12_perubahan_omzet_harian.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q13_kumulatif_rerata_7hari.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q14_rows_vs_range.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q15_riwayat_pembayaran_pelanggan.sql
```

# Langkah 6: Agregasi Lanjutan dan Operasi Himpunan (Q16 - Q18)
```bash
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q16_rollup_kategori_rating.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q17_filter_per_kategori.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q18_rekonsiliasi_inventory_rental.sql
```

# Langkah 7: Mengolah Data JSONB (Q19 - Q20)
```bash
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q19_notifikasi_lunas.sql
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/q20_bentangkan_kontak.sql
```

# Langkah 8: Laporan Pendapatan Bulanan Terpadu (R1)
```bash
docker compose exec -T postgres psql -U postgres -d pagila < latihan/p03/r1_laporan_bulanan.sql
```

---

## Catatan Khusus Q09
Kueri pada berkas q09_rekursi_tahan_siklus.sql melakukan manipulasi relasi atasan sementara (UPDATE pegawai SET atasan_id = 6 WHERE pegawai_id = 1;) untuk menguji ketahanan recursive CTE terhadap infinite loop (siklus tak berujung).

Pastikan baris pemulihan data pada akhir skrip telah dieksekusi agar struktur hierarki tabel pegawai kembali ke kondisi awal:
```sql
UPDATE pegawai SET atasan_id = NULL WHERE pegawai_id = 1;
```

## Anggota
- Tabhita Kristy Silitonga - 251402023 (PM)
- Jevine Jeje Zakarias Simanjuntak - 251402085
- Fadila Lisma Sari - 251402117
- Qairsya Naurel ein Yaliki - 251402120
- Reynald Alvaro Pasaribu - 251402147