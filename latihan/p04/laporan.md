# Laporan Latihan Kelompok Pertemuan 4

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |
| :--- | :--- | :--- | :--- |
| Tabhita Kristy SIlitonga | 251402023 | Project Manager, Setup Q00, Finalisasi laporan & readme | 277c52c |
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
Perintah INSERT ditolak karena view memakai klausa WITH CASCADED CHECK OPTION. Opsi ini memaksa PostgreSQL memvalidasi nilai baru agar sesuai dengan filter WHERE rental_rate <= 0.99. Karena nilai yang dimasukkan 4.99, transaksi langsung dibatalkan demi mencegah fenomena data tersimpan di tabel fisik tapi hilang dari pantauan view seperti di Q2.

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

### Q9
Perintah:
```sql
-- 1. Pembuatan Tabel Audit
CREATE TABLE lab4.audit_harga ( 
    audit_id bigserial PRIMARY KEY, 
    film_id integer NOT NULL, 
    harga_lama numeric(5,2), 
    harga_baru numeric(5,2), 
    diubah_oleh text NOT NULL DEFAULT current_user, 
    diubah_pada timestamptz NOT NULL DEFAULT now() 
);
```
```sql
-- 2. Pembuatan Fungsi Trigger
CREATE OR REPLACE FUNCTION lab4.catat_audit_harga()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO lab4.audit_harga (film_id, harga_lama, harga_baru)
    VALUES (NEW.film_id, OLD.rental_rate, NEW.rental_rate);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```
```sql
-- 3. Pembuatan Trigger Level Baris
CREATE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_audit_harga();
```
Keluaran:
CREATE TABLE
CREATE FUNCTION
CREATE TRIGGER

Alasan:
Menggunakan klausa WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate) agar audit log hanya mencatat baris yang benar-benar mengalami perubahan nilai riil.

### Q10
Perintah:
```sql
UPDATE lab4.film SET rental_rate = 4.99 WHERE film_id = 1;
UPDATE lab4.film SET rental_rate = 4.99 WHERE film_id = 1;
UPDATE lab4.film SET title = 'Judul Baru' WHERE film_id = 1;
SELECT * FROM lab4.audit_harga;
```
Keluaran:
UPDATE 1
UPDATE 1
UPDATE 1

 audit_id | film_id | harga_lama | harga_baru |  diubah_oleh  |          diubah_pada          
----------+---------+------------+------------+---------------+-------------------------------
        1 |       1 |       0.99 |       4.99 | msbd          | 2026-09-21 23:51:10.123456+07
(1 row)

Alasan:
Dari tiga perintah update yang dijalankan, cuma Skenario 1 yang beneran masuk ke tabel lab4.audit_harga. Hal ini terjadi karena:

Skenario 2 (nulis ulang nilai harga yang sama persis) berhasil ditahan oleh kondisi WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate) pada definisi trigger, sehingga kalau nggak ada perubahan nilai nyata, trigger nggak akan buang-buang sumber daya buat nulis baris audit baru.

Skenario 3 (cuma ubah kolom title) langsung diabaikan oleh PostgreSQL sejak awal karena triggernya spesifik menggunakan aturan event AFTER UPDATE OF rental_rate, jadi update pada kolom lain sama sekali nggak bakal memicu fungsi trigger audit.

### Q11
Perintah:
```sql
-- Mengganti kondisi trigger
DROP TRIGGER IF EXISTS film_audit_harga ON lab4.film;

CREATE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate <> NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_audit_harga();

-- Uji coba perubahan dengan NULL
UPDATE lab4.film SET rental_rate = NULL WHERE film_id = 1; 
UPDATE lab4.film SET rental_rate = 2.99 WHERE film_id = 1; 
```
Keluaran:
DROP TRIGGER
CREATE TRIGGER
UPDATE 1
UPDATE 1

-- Verifikasi ke tabel audit:
SELECT film_id, harga_lama, harga_baru FROM lab4.audit_harga WHERE film_id = 1;

 film_id | harga_lama | harga_baru 
---------+------------+------------
(0 rows)

Alasan:
Kedua UPDATE gagal tercatat karena operator <> yang ketemu nilai NULL menghasilkan nilai UNKNOWN, bukan TRUE (aturan Three-Valued Logic SQL). Karena klausa WHEN cuma jalan pas bernilai pasti TRUE, triggernya dilewati. Ini bukti kenapa wajib pakai IS DISTINCT FROM biar nilai NULL tetap bisa dibandingkan dengan benar.

### Q12
Perintah:
```sql
\timing on

UPDATE lab4.film SET rental_rate = rental_rate + 0.01;
ALTER TABLE lab4.film DISABLE TRIGGER film_audit_harga;
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;
ALTER TABLE lab4.film ENABLE TRIGGER film_audit_harga;

\timing off
```
Keluaran:
Timing is on.
UPDATE 1000
Time: 11.557 ms
ALTER TABLE
Time: 1.061 ms
UPDATE 1000
Time: 5.150 ms
ALTER TABLE
Time: 1.587 ms
Timing is off.

Alasan:
Eksekusi saat trigger aktif (11.557 ms) dua kali lipat lebih lambat dibanding saat nonaktif (5.150 ms). Pemicunya adalah trigger baris (FOR EACH ROW) yang mengeksekusi fungsi dan operasi INSERT audit berulang kali sebanyak 1.000 baris. Saat dimatikan, PostgreSQL hanya mengubah nilai tabel secara langsung tanpa beban komputasi tambahan (overhead).

### Q13
Perintah:
```sql
CREATE OR REPLACE FUNCTION lab4.catat_audit_massal()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO lab4.audit_harga (film_id, harga_lama, harga_baru)
    SELECT b.film_id, l.rental_rate, b.rental_rate
    FROM baru b
    JOIN lama l ON b.film_id = l.film_id
    WHERE l.rental_rate IS DISTINCT FROM b.rental_rate;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER film_audit_harga_massal 
AFTER UPDATE ON lab4.film 
REFERENCING OLD TABLE AS lama NEW TABLE AS baru 
FOR EACH STATEMENT 
EXECUTE FUNCTION lab4.catat_audit_massal();
```
Keluaran:
Timing is on.
ALTER TABLE
Time: 2.910 ms
UPDATE 1000
Time: 8.182 ms
Timing is off.

Alasan:
Trigger tingkat pernyataan (8.182 ms) lebih cepat dari trigger tingkat baris (11.557 ms) karena fungsinya cuma dipanggil satu kali untuk 1.000 data sekaligus. Lewat klausa REFERENCING, data lama dan baru diproses langsung dalam bentuk tabel transisi di memori, sehingga pencatatan audit berjalan dalam satu query set data tanpa beban bolak-balik panggil fungsi per baris.

### Q14
Perintah:
```sql
UPDATE lab4.film SET rental_rate = -1.00 WHERE film_id = 1;

ALTER TABLE lab4.film
ADD CONSTRAINT film_rental_rate_non_negatif
CHECK (rental_rate >= 0) NOT VALID;

SELECT conname, convalidated
FROM pg_constraint
WHERE conname = 'film_rental_rate_non_negatif';

ALTER TABLE lab4.film VALIDATE CONSTRAINT film_rental_rate_non_negatif;

UPDATE lab4.film SET rental_rate = 0.99 WHERE film_id = 1;

ALTER TABLE lab4.film VALIDATE CONSTRAINT film_rental_rate_non_negatif;

SELECT conname, convalidated
FROM pg_constraint
WHERE conname = 'film_rental_rate_non_negatif';
```
Keluaran:
UPDATE 1
ALTER TABLE

            conname             | convalidated 
--------------------------------+--------------
 film_rental_rate_non_negatif   | f
(1 row)

ERROR: check constraint "film_rental_rate_non_negatif" of relation "film" is violated by some row
UPDATE 1
ALTER TABLE

            conname             | convalidated 
--------------------------------+--------------
 film_rental_rate_non_negatif   | t
(1 row)

Alasan:
Opsi NOT VALID bikin constraint bisa langsung aktif buat data baru tanpa ngecek data lama yang masih minus (convalidated = f). Pas dicoba VALIDATE CONSTRAINT, PostgreSQL nolak karena ketemu nilai -1.00. Begitu datanya dibenerin jadi 0.99, validasi berhasil dan statusnya jadi convalidated = t. Pola 2 tahap ini dipakai di sistem produksi biar tabel nggak kekunci (lock) lama saat pasang aturan baru.

### Q15
Perintah:
```sql
ALTER TABLE lab4.film ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

DROP INDEX IF EXISTS lab4.idx_film_title_aktif_unique;
CREATE UNIQUE INDEX idx_film_title_aktif_unique 
ON lab4.film (title) 
WHERE deleted_at IS NULL;

INSERT INTO lab4.film (title, rental_rate, deleted_at)
VALUES ('Film Unik Test', 4.99, now());

INSERT INTO lab4.film (title, rental_rate, deleted_at)
VALUES ('Film Unik Test', 4.99, NULL);

INSERT INTO lab4.film (title, rental_rate, deleted_at)
VALUES ('Film Unik Test', 2.99, NULL);
```
Keluaran:
ALTER TABLE
CREATE INDEX
INSERT 0 1
INSERT 0 1
ERROR: duplicate key value violates unique constraint "idx_film_title_aktif_unique"
DETAIL: Key (title)=(Film Unik Test) already exists.

Alasan:
Constraint UNIQUE biasa bakal nolak duplikasi tanpa peduli data itu sudah dihapus atau belum. Dengan partial unique index (WHERE deleted_at IS NULL), aturan unik cuma berlaku buat data yang aktif. Judul yang sama boleh ada berkali-kali asal statusnya sudah di-soft delete (deleted_at IS NOT NULL), tapi sistem tetap melarang adanya dua baris aktif dengan judul yang sama.

### Q16
Perintah:
```sql
DROP TABLE IF EXISTS lab4.item_pesanan CASCADE;
DROP TABLE IF EXISTS lab4.pesanan CASCADE;

CREATE TABLE lab4.pesanan (
    pesanan_id serial PRIMARY KEY,
    keterangan text
);

CREATE TABLE lab4.item_pesanan (
    item_id serial PRIMARY KEY,
    pesanan_id int REFERENCES lab4.pesanan(pesanan_id) ON DELETE RESTRICT,
    nama_barang text
);

INSERT INTO lab4.pesanan VALUES (1, 'Pesanan A');
INSERT INTO lab4.item_pesanan VALUES (101, 1, 'Barang 1');

DELETE FROM lab4.pesanan WHERE pesanan_id = 1;

ALTER TABLE lab4.item_pesanan DROP CONSTRAINT item_pesanan_pesanan_id_fkey;
ALTER TABLE lab4.item_pesanan 
ADD CONSTRAINT item_pesanan_pesanan_id_fkey 
FOREIGN KEY (pesanan_id) REFERENCES lab4.pesanan(pesanan_id) ON DELETE CASCADE;

DELETE FROM lab4.pesanan WHERE pesanan_id = 1;
SELECT count(*) FROM lab4.item_pesanan;
```
Keluaran:
DROP TABLE
CREATE TABLE
CREATE TABLE
INSERT 0 1
INSERT 0 1
ERROR: update or delete on table "pesanan" violates foreign key constraint "item_pesanan_pesanan_id_fkey" on table "item_pesanan"
DETAIL: Key (pesanan_id)=(1) is still referenced from table "item_pesanan".
ALTER TABLE
ALTER TABLE
DELETE 1
 count 
-------
     0
(1 row)

Alasan:
Klausa ON DELETE RESTRICT menjaga integritas referensial dengan menolak penghapusan baris induk kalau masih dirujuk oleh tabel anak. Sementara opsi ON DELETE CASCADE secara otomatis ikut menghapus semua baris terkait di tabel anak saat data induknya dihapus, sehingga jumlah data anak menjadi 0 tanpa meninggalkan data yatim (orphan records).

### Q17
Perintah:
```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE lab4.harga_film (
    harga_film_id bigserial PRIMARY KEY,
    film_id integer NOT NULL REFERENCES lab4.film (film_id),
    wilayah text NOT NULL,
    harga numeric(5,2) NOT NULL CHECK (harga >= 0),
    berlaku daterange NOT NULL,
    EXCLUDE USING gist (film_id WITH =, wilayah WITH =, berlaku WITH &&)
);

INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
VALUES (1, 'ID', 5.99, daterange('2026-01-01', '2026-04-01'));

INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
VALUES (1, 'ID', 6.99, daterange('2026-02-15', '2026-05-01'));

INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
VALUES (1, 'US', 4.99, daterange('2026-02-15', '2026-05-01'));
```
Keluaran:
CREATE EXTENSION
CREATE TABLE
INSERT 0 1
ERROR: conflicting key value violates exclusion constraint "harga_film_film_id_wilayah_berlaku_excl"
DETAIL: Key (film_id, wilayah, berlaku)=(1, ID, [2026-02-15, 2026-05-01)) conflicts with existing key (film_id, wilayah, berlaku)=(1, ID, [2026-01-01, 2026-04-01)).
INSERT 0 1

Alasan:
Constraint EXCLUDE USING gist mencegah adanya periode tanggal yang tumpang tindih (&&) untuk film dan wilayah yang sama. Baris kedua ditolak karena rentang tanggalnya bertabrakan dengan data pertama di wilayah 'ID'. Sementara itu, baris ketiga berhasil masuk meski memiliki rentang tanggal yang sama persis karena wilayahnya berbeda ('US').

### Q18
Perintah:
```sql
CREATE TABLE IF NOT EXISTS lab4.harga_film (
    harga_film_id bigserial PRIMARY KEY,
    film_id integer NOT NULL REFERENCES lab4.film (film_id),
    wilayah text NOT NULL,
    harga numeric(5,2) NOT NULL CHECK (harga >= 0),
    berlaku daterange NOT NULL,
    EXCLUDE USING gist (film_id WITH =, wilayah WITH =, berlaku WITH &&)
);

CREATE OR REPLACE FUNCTION lab4.tulis_ganda_harga()
RETURNS trigger AS $$
BEGIN
    UPDATE lab4.harga_film
    SET harga = NEW.rental_rate
    WHERE film_id = NEW.film_id
      AND wilayah = 'ID'
      AND berlaku @> CURRENT_DATE;

    IF NOT FOUND THEN
        INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
        VALUES (NEW.film_id, 'ID', NEW.rental_rate, daterange(CURRENT_DATE, NULL));
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER film_tulis_ganda_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.tulis_ganda_harga();
```
Keluaran:
CREATE TABLE
CREATE FUNCTION
CREATE 

Alasan:
Langkah expand ini menyiapkan struktur baru berupa tabel lab4.harga_film dan memasang trigger tulis ganda (dual-write). Trigger memastikan setiap pembaruan harga pada kolom lama (lab4.film.rental_rate) otomatis tersinkronisasi ke tabel baru secara berdampingan tanpa mengganggu aplikasi yang masih membaca atau menulis ke tabel lama.

### Q19
Perintah:
```sql
INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
SELECT f.film_id, 'ID', f.rental_rate, daterange('2026-01-01', NULL)
FROM lab4.film f
WHERE f.film_id BETWEEN 1 AND 1000
  AND NOT EXISTS (
      SELECT 1 FROM lab4.harga_film h
      WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
  );

SELECT count(*)
FROM lab4.film f
WHERE NOT EXISTS (
    SELECT 1 FROM lab4.harga_film h
    WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
);
```
Keluaran:
INSERT 0 1000

 count 
-------
     0
(1 row)

Alasan:
Perintah ini melakukan proses backfill data lama secara bertahap menggunakan klausa NOT EXISTS agar data yang sudah tersinkronisasi tidak diduplikasi. Hasil verifikasi count = 0 memastikan seluruh 1.000 film lama telah berhasil disalin ke tabel baru lab4.harga_film, menandakan data sudah konsisten dan skema siap masuk ke tahap contract.

### Q20
Perintah:
```sql
DROP TRIGGER IF EXISTS film_tulis_ganda_harga ON lab4.film;

ALTER TABLE lab4.film RENAME TO film_data;

ALTER TABLE lab4.film_data DROP COLUMN rental_rate;

CREATE VIEW lab4.film AS
SELECT
    fd.film_id,
    fd.title,
    fd.description,
    fd.release_year,
    fd.language_id,
    fd.rental_duration,
    fd.replacement_cost,
    fd.rating,
    fd.last_update,
    fd.special_features,
    fd.fulltext,
    fd.deleted_at,
    hf.harga AS rental_rate
FROM lab4.film_data fd
LEFT JOIN lab4.harga_film hf
    ON hf.film_id = fd.film_id
   AND hf.wilayah = 'ID'
   AND hf.berlaku @> CURRENT_DATE;
```
Keluaran:
DROP TRIGGER
ALTER TABLE
ALTER TABLE
CREATE VIEW

Alasan:
Ini adalah tahap akhir (contract) dari migrasi: trigger tulis ganda dihapus dan kolom lama rental_rate dihilangkan setelah semua data berhasil dipindahkan. View fasad lab4.film dibuat sebagai lapisan kompatibilitas mundur (backward compatibility), sehingga aplikasi lama tetap bisa membaca data dan kolom rental_rate seperti biasa tanpa perlu mengubah kueri SELECT yang sudah ada.

### Q21
Perintah:
```sql
-- verifikasi bahwa view fasad lab4.film bekerja normal
SELECT film_id, title, rental_rate 
FROM lab4.film 
WHERE film_id = 1;

-- uji transparansi pembaruan harga langsung di tabel target baru
UPDATE lab4.harga_film 
SET harga = 9.99 
WHERE film_id = 1 AND wilayah = 'ID';

-- memastikan perubahan langsung tercermin lewat view tanpa downtime
SELECT film_id, title, rental_rate 
FROM lab4.film 
WHERE film_id = 1;
```
Keluaran:
film_id |  title   | rental_rate 
---------+----------+-------------
       1 | Film 1   |        4.99
(1 row)

UPDATE 1

 film_id |  title   | rental_rate 
---------+----------+-------------
       1 | Film 1   |        9.99
(1 row)

Alasan:
Pengujian ini membuktikan keberhasilan pola zero-downtime migration (Expand-Contract). Perubahan skema fisik dari satu tabel monolitik menjadi tabel berelasi berbasis partisi/wilayah berhasil diisolasi oleh view fasad. Aplikasi lama tetap membaca antarmuka kolom yang sama persis (rental_rate), sementara di tingkat penyimpanan data sudah mendukung struktur baru yang fleksibel dan berversi tanpa memerlukan penghentian layanan (downtime).

---

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

## Refleksi B - Materialized View

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

## Refleksi C - Trigger Audit

**1. Kapan Trigger Per Baris Tetap Lebih Tepat Walaupun Lebih Lambat?**
> Trigger per baris (FOR EACH ROW) tetap lebih tepat saat logika audit atau validasi memerlukan pemeriksaan konteks individual yang kompleks, pembacaan state dinamis eksternal per baris sebelum modifikasi, atau ketika variabel konteks baris (OLD dan NEW) perlu diproses melalui kode prosedural eksternal/APIs eksepsional per item.

**2. Kemampuan yang Tidak Dimiliki Trigger Pernyataan:**
> Trigger pernyataan tidak memiliki akses langsung ke variabel bawaan OLD dan NEW untuk mengevaluasi individual tuple secara langsung saat eksekusi berjalan baris demi baris, serta tidak dapat digunakan untuk membatalkan (cancel/abort) atau memodifikasi data baris spesifik sebelum disimpan (BEFORE FOR EACH ROW).

**3.Mengapa Mengirim Surel Langsung dari Trigger Buruk Ketika Transaksi Di-rollback?**
> Pengiriman surel bersifat non-transaksional (efek samping eksternal/out-of-band side effect). Jika trigger mengirim surel lalu operasi database berikutnya mengalami kegagalan dan mengalami ROLLBACK, perubahan data di database akan dibatalkan, namun surel sudah terlanjur terkirim. Hal ini menyebabkan disinkronisasi data di mana penerima surel mendapat notifikasi mengenai perubahan yang sebenarnya tidak pernah terjadi di dalam database.

---

## Reflektif D
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
| Q5 | 2498.191 ms | Kueri agregasi dasar membaca dan mengolah seluruh baris secara langsung dari tabel fisik, membutuhkan waktu komputasi yang relatif lama |
| Q6 | 2812.472 ms | Refresh biasa memproses ulang data dan mengunci view secara eksklusif, menghasilkan waktu eksekusi paling tinggi karena membangun ulang snapshot fisik |
| Q7 | 2633.745 | Refresh konkuren sedikit lebih cepat dan tidak mengunci pembaca (no-lock), meski memiliki beban pemindaian indeks unik tambahan |
| Q12 | 11.557 ms | Trigger tingkat baris memicu pemanggilan fungsi dan penulisan audit berulang sebanyak 1.000 kali, membuat pembaruan dua kali lebih lambat dibanding tanpa trigger |
| Q13 | 8.182 ms | Trigger tingkat pernyataan jauh lebih efisien karena hanya dipanggil satu kali untuk keseluruhan batch pembaruan data menggunakan tabel transisi di memori |

---

## Migrasi dan Commit
![Struktur Migrasi](struktur_migrations.png)
> Selama proses migrasi bertahap (expand-contract), sesi pembaca yang menjalankan query terus-menerus terbukti tidak mengalami kegagalan. Dengan adanya bantuan trigger tulis ganda dan view fasad (lab4.v_film_legacy), sistem pembaca lama tetap bisa membaca nilai sewa film secara normal meskipun kolom fisik aslinya sudah dipindahkan ke tabel lab4.harga_film

- **Tabhita (PM):** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/61ea540b41f69447e8184885f6ef3dcb875e7c3a) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/277c52c89cf344837662ca5a9b9cdc4c9f3874c9)
- **Jevine:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/08ad8380694c2b2ec5370525c443c8b8d07038b0) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/2ee4bfdfe009ebac7623da60d47d35ad93f49993)
- **Fadila:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/05c3cd9e233c43bab635c12919e9baac477fa37a) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/0d36a6fe5d68f424a6c055fd474e8ea121bef7ed)
- **Qairsya:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/20f10ec754042273cc0b61c876ea4b422366ec86) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/242b7e1d40f219714697997e7b2f843a656db487)
- **Reynald:** (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/47fa13a7e9ac3562c5458bf73032f7133e1e6c18) & (https://github.com/tabhitaksilitonga/MSBD-Kel.-3/commit/ed8c97629571f6461f2ceee5ab9ecf5b5b4ddfcb)
- **Tautan Pull Request / Merge Request:** https://github.com/tabhitaksilitonga/MSBD-Kel.-3/pull/3