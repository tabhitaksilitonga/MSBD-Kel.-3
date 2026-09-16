# Laporan Latihan Kelompok Pertemuan 4

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |
| :--- | :--- | :--- | :--- |
| Tabhita Kristy SIlitonga | 251402023 | Project Manager, Setup Q00, Finalisasi laporan & readme | ab2e387 |
| Jevine Jeje Zakarias Simanjuntak | 251402085 | Langkah 2 (Q01-Q04) View & WITH CHECK OPTION, Refleksi A | 2ee4bfd |
| Fadila Lisma Sari | 251402117 | Langkah 3 (Q05-Q08) Materialized View & Concurrent Refresh, Refleksi B | 0d36a6f |
| Qairsya Naurel ein Yaliki | 251402120 | Langkah 4 (Q09-Q13) Trigger Audit Baris & Pernyataan, Refleksi C | 9bb7819 |
| Reynald Alvaro Pasaribu | 251402147 | Langkah 5 & 6 (Q14-Q21) Constraint & Expand-Contract, Refleksi D & E | ed8c976 |

---

## Q1–Q21
### Q1
Perintah:
```sql
CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate < 0.99;
```
Keluaran:
CREATE VIEW

Alasan:
Memenuhi permintaan view fasad sederhana tanpa proteksi WITH CHECK OPTION terlebih dahulu untuk melihat perilaku updatable view bawaan PostgreSQL

### Q2
Perintah:
```sql
INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating, language_id)
VALUES (9999, 'Film Uji Q2', 4.99, 'G', 1);

SELECT 'View film_murah' AS sumber_data, COUNT(*) AS jumlah_baris 
FROM lab4.film_murah WHERE title = 'Film Uji Q2'
UNION ALL
SELECT 'Tabel dasar film' AS sumber_data, COUNT(*) AS jumlah_baris 
FROM lab4.film WHERE title = 'Film Uji Q2';
```
Keluaran:
INSERT 0 1

   sumber_data    | jumlah_baris 
------------------+--------------
 View film_murah  |            0
 Tabel dasar film |            1
(2 rows)

Alasan:
MData berhasil masuk ke tabel dasar film karena view ini masih sederhana dan bisa menerima insert. Tapi pas dicek lewat view nilainya 0 (beda sama tabel dasar yang isinya 1) karena dari awal view film_murah belum dikasih WITH CHECK OPTION. Jadinya PostgreSQL ngebiarin aja data harga 4.99 masuk ke tabel utama, padahal data itu nggak lolos filter WHERE rental_rate < 0.99 makanya nggak muncul di view.

### Q3
Perintah:
```sql
DROP VIEW IF EXISTS lab4.film_murah;

CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99
WITH CASCADED CHECK OPTION;

INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating, language_id)
VALUES (9998, 'Film Uji Q3', 4.99, 'G', 1);
```
Keluaran:
DROP VIEW
CREATE VIEW
ERROR: new row violates check option for view "film_murah"
DETAIL: Failing row contains (9998, Film Uji Q3, null, null, 1, 6, 4.99, null, null, null, G, null, 2026-09-16 ...).

Alasan:
Perintah insert kali ini langsung ditolak sama PostgreSQL dan memunculkan error pelanggaran check option. Soalnya di pembuatan view baru sudah ditambahin klausa WITH CASCADED CHECK OPTION. Klausa ini fungsinya buat ngejaga integritas data, jadi PostgreSQL bakal ngecek dulu apakah data yang mau dimasukin cocok sama kondisi WHERE rental_rate <= 0.99. Karena kita maksa masukin nilai 4.99, operasinya langsung dibatalkan biar nggak ada lagi kejadian data tembus ke tabel dasar tapi hilang dari view kayak di Q2.

### Q4
Perintah:
```sql
CREATE OR REPLACE VIEW lab4.pendapatan_kategori AS
SELECT rating AS kategori, SUM(rental_rate) AS total_pendapatan, COUNT(film_id) AS jumlah_film
FROM lab4.film
GROUP BY rating;

INSERT INTO lab4.pendapatan_kategori (kategori, total_pendapatan, jumlah_film)
VALUES ('PG-13', 150.00, 10);
```
Keluaran:
CREATE VIEW
ERROR: cannot insert into view "pendapatan_kategori"
DETAIL: Views containing GROUP BY are not automatically updatable.
HINT: To enable inserting into the view, provide an INSTEAD OF trigger or an unconditional ON INSERT DO INSTEAD rule.

Alasan:
Operasi INSERT langsung error karena view ini bukan tipe yang bisa di update otomatis. Di dalam query pembentuk view ada klausa GROUP BY dan fungsi agregasi (SUM serta COUNT). PostgreSQL bingung mau nyisipin baris baru ke tabel fisik aslinya (lab4.film) karena satu baris di view ini mewakili gabungan dari banyak baris data, bukan record tunggal. Kalau mau view kayak gini bisa nerima data, kita harus bikin trigger INSTEAD OF manual dulu.

### Q5
Perintah:
```sql
SELECT date_trunc('month', a.waktu) AS bulan,
       a.kanal,
       count(*) AS jumlah_akses,
       count(DISTINCT a.film_id) AS film_unik
FROM lab4.jejak_akses a
GROUP BY 1, 2
ORDER BY 1, 2;
```
Keluaran:
bulan          |  kanal  | jumlah_akses | film_unik 
------------------------+---------+--------------+-----------
 2025-09-01 00:00:00+07 | android |        20540 |      1000
 2025-09-01 00:00:00+07 | ios     |        20412 |      1000
 2025-09-01 00:00:00+07 | kiosk   |        20678 |      1000
 2025-09-01 00:00:00+07 | web     |        20815 |      1000
 ... (baris ringkasan bulan lainnya)
(48 rows)
Time: 238.412 ms

Alasan:
Query agregasi ini dipakai buat tolak ukur performa membaca dan mengolah 500.000 baris data di lab4.jejak_akses. Tanpa bantuan caching atau indexing, database harus membaca seluruh isi tabel (Seq Scan) dan menghitung operasi berat seperti count(DISTINCT) secara langsung, sehingga waktu eksekusinya relatif lama. Angka waktu ini nantinya dipakai sebagai bahan perbandingan saat memakai materialized view di Q6 dan Q7.

### Q6
Perintah:
```sql
DROP MATERIALIZED VIEW IF EXISTS lab4.ringkasan_akses;

CREATE MATERIALIZED VIEW lab4.ringkasan_akses AS
SELECT date_trunc('month', a.waktu) AS bulan,
       a.kanal,
       count(*) AS jumlah_akses,
       count(DISTINCT a.film_id) AS film_unik
FROM lab4.jejak_akses a
GROUP BY 1, 2
ORDER BY 1, 2
WITH NO DATA;

SELECT * FROM lab4.ringkasan_akses;

REFRESH MATERIALIZED VIEW lab4.ringkasan_akses;
```
Keluaran:
-Saat dibaca sebelum refresh
ERROR: materialized view "ringkasan_akses" has not been populated
HINT: Use the REFRESH MATERIALIZED VIEW command.

-Saat refresh pertama
REFRESH MATERIALIZED VIEW
Time: 1830.936 ms

Alasan:
Materialized view sengaja dibuat pakai opsi WITH NO DATA biar pembuatan objek skemanya cepat tanpa harus langsung memproses data berat di awal. Dampaknya, databasenya menolak query baca dan memunculkan error karena fisiknya memang belum terisi. Data baru benar-benar dihitung dan disimpan ke disk setelah kita menjalankan perintah REFRESH MATERIALIZED VIEW.

### Q7
Perintah:
```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;

CREATE UNIQUE INDEX ux_ringkasan_akses_bulan_kanal
ON lab4.ringkasan_akses (bulan, kanal);

REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;
```
Keluaran:
-Sebelum ada index unik
ERROR: cannot refresh materialized view "lab4.ringkasan_akses" concurrently
HINT: Create a full-table unique index with no WHERE clause on one or more columns of the materialized view.

-Setelah ada index unik
CREATE INDEX
REFRESH MATERIALIZED VIEW
Time: 2785.430 ms

Alasan:
Opsi CONCURRENTLY wajib punya unique index (di sini pakai kombinasi bulan dan kanal) karena PostgreSQL butuh acuan unik buat membandingkan data snapshot lama dan baru (diffing). Waktu eksekusinya jadi lebih lama (sekitar 2785 ms dibanding refresh biasa 1830 ms) karena ada beban komputasi ekstra: sistem harus menulis data sementara ke tabel temporary, membandingkan perubahannya, baru memperbarui baris dan index uniknya satu per satu.

### Q8
Perintah:
```sql
INSERT INTO lab4.jejak_akses (film_id, waktu, kanal)
SELECT (random() * 999)::int + 1, now(), 'web'
FROM generate_series(1, 200000);

REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;
```
```sql
SELECT count(*) FROM lab4.ringkasan_akses;
```

Keluaran:
-Sesi 1
INSERT 0 200000 (Time: 1851.303 ms)
REFRESH MATERIALIZED VIEW (Time: 2785.430 ms)

-Sesi 2
count
-------
   52
(1 row)
Time: 5.106 ms

Alasan:
Pengujian dua sesi ini membuktikan kalau refresh dengan mode CONCURRENTLY tidak memblokir pengguna lain yang mau membaca data. Sesi 2 bisa langsung membaca isi materialized view cuma dalam waktu 5.106 ms tanpa harus antre menunggu Sesi 1 selesai menyisipkan 200.000 data dan me-refresh view. Beda halnya kalau memakai refresh biasa, Sesi 2 bakal tertahan (blocked) karena refresh biasa mengunci tabel secara penuh (exclusive lock).

## Refleksi A - View dan WITH CHECK OPTION

**1. Sebuah tim menempatkan seluruh akses aplikasi melalui view dengan alasan lebih aman dan lebih rapi. Sebutkan dua keuntungan, dua kerugian, dan satu keadaan konkret ketika pendekatan ini justru mempersulit tim berdasarkan pengamatan Q1–Q4.**
> Keuntungan:
1. lebih aman buat data. view bisa nyembunyiin kolom-kolom sensitif dari tabel asli. jadi, aplikasi atau user cuma bisa akses data yang emang diizinin aja, nggak bisa intip sembarangan.
2. kode aplikasi jadi lebih bersih. query yg tadinya ribet udah dibungkus rapi di view. jadi backend tinggal SELECT simpel aja tanpa perlu mikirin logika database yang ruwet di sisi kode program.
Kerugian:
1. nggak fleksibel buat operasi tulis (INSERT/UPDATE/DELETE). Nggak semua view bisa dimodifikasi datanya secara langsung, apalagi kalau view-nya pakai fungsi agregat atau aturan filter yang ketat.
2. ribet pas maintenance. Kalau struktur tabel aslinya berubah (misal nama kolom diganti atau tabelnya di-drop), view yang bergantung sama tabel itu bakal langsung error dan harus dibenerin manual satu per satu.
Keadaan konkret yang malah mempersulit tim:
misal tim developer disuruh masukin data film baru yang harga sewanya normal (misal 4.99) lewat view film_murah (kayak di Q3). itu pasti langsung ditolak sama database karena melanggar CHECK OPTION atau pas mau input data rekap pendapatan (kayak di Q4), pasti error juga karena view yang pakai GROUP BY emang nggak bisa di-insert langsung. jadinya, developer bakal stuck, mau nggak mau mereka harus bikin trigger INSTEAD OF yang logikanya ribet, atau malah nekat bypass view dan akses tabel dasar langsung. padahal tujuan awal arsitekturnya kan biar aksesnya terpusat dan rapi, eh malah jadi penghambat workflow tim sendiri pas butuh fitur input data yang nggak sesuai sama kriteria view.

---

## Refleksi C - Trigger Audit

**1. Kapan Trigger Per Baris Tetap Lebih Tepat Walaupun Lebih Lambat?**
> Trigger per baris (FOR EACH ROW) tetap lebih tepat saat logika audit atau validasi memerlukan pemeriksaan konteks individual yang kompleks, pembacaan state dinamis eksternal per baris sebelum modifikasi, atau ketika variabel konteks baris (OLD dan NEW) perlu diproses melalui kode prosedural eksternal/APIs eksepsional per item.

**2. Kemampuan yang Tidak Dimiliki Trigger Pernyataan:**
> Trigger pernyataan tidak memiliki akses langsung ke variabel bawaan OLD dan NEW untuk mengevaluasi individual tuple secara langsung saat eksekusi berjalan baris demi baris, serta tidak dapat digunakan untuk membatalkan (cancel/abort) atau memodifikasi data baris spesifik sebelum disimpan (BEFORE FOR EACH ROW).

**3.Mengapa Mengirim Surel Langsung dari Trigger Buruk Ketika Transaksi Di-rollback?**
> Pengiriman surel bersifat non-transaksional (efek samping eksternal/out-of-band side effect). Jika trigger mengirim surel lalu operasi database berikutnya mengalami kegagalan dan mengalami ROLLBACK, perubahan data di database akan dibatalkan, namun surel sudah terlanjur terkirim. Hal ini menyebabkan disinkronisasi data di mana penerima surel mendapat notifikasi mengenai perubahan yang sebenarnya tidak pernah terjadi di dalam database.

---

## Refleksi C - Materialized View

**1. Tim keuangan menginginkan laporan yang selalu mutakhir sekaligus selalu cepat. Jelaskan trade-off materialized view dan usulkan kompromi konkret: batas kebasian, jadwal refresh, dan tindakan saat refresh gagal di tengah jalan.**
> Materialized view mempercepat laporan karena hasil query sudah disimpan, tapi datanya tidak selalu terbaru. Komprominya, laporan dapat ditetapkan memiliki batas kebasian, misalnya 15 menit, dengan refresh setiap 15 menit. Jika refresh gagal, gunakan hasil refresh terakhir yang berhasil dan lakukan percobaan ulang setelah masalah diperbaiki.
## LANGKAH 3 · MATERIALIZED VIEW

### Q5
Query digunakan untuk menampilkan jumlah akses dan jumlah film unik berdasarkan bulan dan kanal.

Waktu eksekusi: `Time: 2498.191 ms (00:02.498)`

### Q6
Query Q5 dibuat menjadi materialized view `lab4.ringkasan_akses` dengan `WITH NO DATA`. Pada pengujian ulang, materialized view sudah tersedia sehingga tidak dilakukan pembuatan ulang.

Setelah refresh biasa, data berhasil dimuat.

Waktu refresh: `2812.472 ms`

### Q7
Pada pengujian ulang, materialized view sudah memiliki index yang diperlukan sehingga `REFRESH MATERIALIZED VIEW CONCURRENTLY` berhasil dijalankan.

Waktu refresh concurrently: `2633.745 ms`

Refresh concurrently tetap memiliki proses tambahan untuk menjaga agar pembaca dapat mengakses materialized view selama refresh.

### Q8
Pada refresh concurrently, pembaca tetap dapat menjalankan query saat proses refresh berlangsung. Pada refresh biasa, pembaca dapat menunggu hingga proses refresh selesai.

---

### Reflektif D
**Aturan periode harga tidak tumpang tindih dapat ditulis sebagai trigger yang membaca tabel sebelum INSERT. Jelaskan mengapa trigger itu bisa gagal ketika dua transaksi berjalan bersamaan, sedangkan EXCLUDE tidak, dengan bahasa Anda sendiri.** 
> Trigger BEFORE INSERT yang cek manual bisa kebobolan saat dua transaksi jalan bersamaan: keduanya sama-sama SELECT dulu buat cek tumpang tindih, tapi karena masing-masing belum lihat perubahan punya yang lain (belum commit), keduanya lolos pengecekan dan sama-sama berhasil insert — padahal harusnya bentrok. Ini race condition, karena ada jeda antara "cek" dan "insert" yang gak terlindungi.EXCLUDE gak kena masalah ini karena pengecekan dan penguncian jadi satu operasi atomik di level index GiST — begitu satu transaksi insert, baris yang bentrok langsung ketahan/gagal, gak ada celah waktu buat transaksi lain nyelip.

---

## Reflektif E
**Berapa lama jarak rilis yang Anda usulkan antara 0045 dan 0046? Bukti apa yang harus dikumpulkan sebelum berani menjalankan 0046, mengingat isinya tidak dapat dikembalikan sepenuhnya?**
> Jarak yang kami usulin: minimal satu siklus rilis penuh (~1-2 minggu), soalnya 0046 ngehapus kolom rental_rate secara permanen dan .down.sql-nya cuma bisa balikin strukturnya, bukan datanya.

---

## Ringkasan Waktu
| Tugas | Waktu | Penafsiran |
|---|---:|---|
| Q5 | | |
| Q6 | | |
| Q7 | | |
| Q12 | | |
| Q13 | | |

---

## Migrasi dan Commit
![Struktur Migrasi](struktur_migrations.png)
> Selama proses migrasi bertahap (expand-contract), sesi pembaca yang menjalankan query terus-menerus terbukti tidak mengalami kegagalan. Dengan adanya bantuan trigger tulis ganda dan view fasad (lab4.v_film_legacy), sistem pembaca lama tetap bisa membaca nilai sewa film secara normal meskipun kolom fisik aslinya sudah dipindahkan ke tabel lab4.harga_film

- **Tabhita (PM):** [Tautan/Hash commit setup lab Q00 & inisialisasi laporan]
- **Jevine:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/08ad8380694c2b2ec5370525c443c8b8d07038b0) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/2ee4bfdfe009ebac7623da60d47d35ad93f49993)
- **Fadila:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/05c3cd9e233c43bab635c12919e9baac477fa37a) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/0d36a6fe5d68f424a6c055fd474e8ea121bef7ed)
- **Qairsya:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/20f10ec754042273cc0b61c876ea4b422366ec86) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/242b7e1d40f219714697997e7b2f843a656db487)
- **Reynald:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/47fa13a7e9ac3562c5458bf73032f7133e1e6c18) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/ed8c97629571f6461f2ceee5ab9ecf5b5b4ddfcb)
- **Tautan Pull Request / Merge Request:** https://github.com/tabhitaksilitonga/MSBD-Kel.-3/pull/3