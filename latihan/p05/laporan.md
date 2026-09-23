# Laporan Latihan Kelompok Pertemuan 5



## Q1-Q24

### Q6 — Domain positive_amount

Perintah:
INSERT INTO lab5.payment_tx (rental_id, amount)
VALUES (1, 0);

INSERT INTO lab5.payment_tx (rental_id, amount)
VALUES (1, -10);

Keluaran:
ERROR: 23514: value for domain lab5.positive_amount violates check constraint "positive_amount_check"

ERROR: 23514: value for domain lab5.positive_amount violates check constraint "positive_amount_check"

Alasan keputusan:
Domain lab5.positive_amount digunakan untuk memastikan nilai pembayaran
harus lebih besar dari 0. Nilai 0 dan negatif ditolak oleh constraint
VALUE > 0. SQLSTATE 23514 menunjukkan pelanggaran check constraint.

### Q7 — ENUM rental_status

Perintah:
UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;

Keluaran:
ERROR: 22P02: invalid input value for enum lab5.rental_status: "EXPIRED"

ALTER TYPE lab5.rental_status
ADD VALUE 'EXPIRED';

Keluaran:
ALTER TYPE

Percobaan ulang:
UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;

Keluaran:
UPDATE 1

Verifikasi:
SELECT rental_id, status
FROM lab5.rental_tx
WHERE rental_id = 1;

Keluaran:
rental_id | status
----------+--------
1         | EXPIRED

Alasan keputusan:
ENUM digunakan untuk membatasi nilai status rental. Nilai EXPIRED
awalnya tidak diperbolehkan, tetapi setelah ditambahkan menggunakan
ALTER TYPE, nilai tersebut dapat digunakan.

### Q8 — Array Tags

Perintah:
UPDATE lab5.rental_tx
SET tags = ARRAY['promo','akhir-pekan','anggota']
WHERE rental_id = 1;

Keluaran:
UPDATE 1

Perintah:
SELECT rental_id, tags
FROM lab5.rental_tx
WHERE 'promo' = ANY(tags);

Keluaran:
rental_id | tags
----------+-----------------------------
1         | {promo,akhir-pekan,anggota}

Alasan keputusan:
Array digunakan untuk menyimpan beberapa tag dalam satu kolom.
Operator ANY digunakan untuk mencari baris yang memiliki tag tertentu,
yaitu 'promo'.

### Q9 — JSONB Metadata

Perintah:
UPDATE lab5.rental_tx
SET metadata = '{"channel":"web","device":"android"}'::jsonb
WHERE rental_id = 1;

Keluaran:
UPDATE 1

Perintah:
SELECT rental_id, metadata ->> 'channel' AS kanal
FROM lab5.rental_tx
WHERE rental_id = 1;

Keluaran:
rental_id | kanal
----------+-------
1         | web

Alasan keputusan:
JSONB digunakan untuk menyimpan metadata yang memiliki struktur
key-value. Operator ->> digunakan untuk mengambil nilai channel
sebagai teks dari data JSONB.


## Reflektif B

Saya memilih ags untuk dianalisis. Menurut saya, tags sebaiknya tetap disimpan dalam bentuk array pada kolom `tags` karena satu rental dapat memiliki beberapa tag dan tag tersebut hanya berfungsi sebagai informasi tambahan. Dengan array, beberapa tag dapat disimpan dalam satu baris tanpa membutuhkan tabel tambahan.

Namun, keputusan tersebut dapat berubah jika kebutuhan bisnis menjadi lebih kompleks. Misalnya, jika bisnis membutuhkan pertanyaan seperti “Berapa banyak rental yang menggunakan setiap tag dan bagaimana penggunaan tag tersebut berubah setiap bulan?”, maka tags lebih tepat dipindahkan ke tabel terpisah agar setiap tag dapat dikelola, dihitung, dan dianalisis dengan lebih mudah.


## reflektif c
Soal: Bandingkan rollback Q3 yang dipicu basis data dan Q13 yang dipicu Python. Apa persamaannya, dan apa satu hal yang hanya dapat dilakukan oleh sisi aplikasi?
Jawaban: Persamaannya, keduanya membuktikan sebuah transaksi yang belum di-COMMIT tidak pernah menyisakan perubahan sebagian (partial write). Di Q3, PostgreSQL sendiri yang menolak karena amount melanggar domain positive_amount, jadi seluruh transaksi (termasuk INSERT rental_tx yang sudah berjalan) dibatalkan otomatis oleh server. Di Q13, kegagalannya bukan dari basis data (procedure-nya sukses tanpa galat SQL) — kegagalannya dari logika Python (RuntimeError) sebelum blok with conn sempat commit, sehingga psycopg yang melakukan ROLLBACK otomatis.
Satu hal yang hanya bisa dilakukan sisi aplikasi: membatalkan transaksi karena alasan yang sama sekali tidak diketahui basis data — misalnya API eksternal gagal, validasi bisnis tambahan, timeout, atau keputusan user membatalkan proses. Basis data tidak tahu apa-apa soal RuntimeError kita; kalau hanya mengandalkan SQL, statement itu tetap valid dan akan ikut ter-commit begitu saja.
