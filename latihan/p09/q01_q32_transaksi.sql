# LANGKAH 1 Q1–Q5: Setup dan Batas Transaksi

## Q1: Memeriksa data awal dan total saldo keseluruhan
SELECT *, (SELECT SUM(saldo) FROM lab9.rekening) AS total_saldo 
FROM lab9.rekening 
ORDER BY rekening_id;

## Q2: Transaksi Sesi A tanpa COMMIT
### Sesi A:
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 200000 WHERE rekening_id = 1;
### Sesi B (Jalankan di tab sebelah):
SELECT * FROM lab9.rekening ORDER BY rekening_id;

## Q3: Menguji COMMIT dan ROLLBACK
### Sesi A (Commit transaksi Q2):
COMMIT;
### Sesi A (Uji Rollback):
BEGIN;
UPDATE lab9.rekening SET saldo = 500000 WHERE rekening_id = 1;
ROLLBACK;

## Q4: Menguji SAVEPOINT
BEGIN;
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 1;
SAVEPOINT titik_titip;
UPDATE lab9.rekening SET saldo = saldo + 500000 WHERE rekening_id = 2;
ROLLBACK TO SAVEPOINT titik_titip;
COMMIT;

SELECT * FROM lab9.rekening ORDER BY rekening_id;

# LANGKAH 2 Q6–Q11: Transaksi Konkurensi

## Q6: Menguji READ COMMITTED
### Sesi A:
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;

### Sesi B:
BEGIN;
UPDATE lab9.rekening SET saldo = saldo + 50000 WHERE rekening_id = 1;
COMMIT;

### Sesi A:
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
COMMIT;


## Q7: Menguji REPEATABLE READ
### Sesi A:
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;

### Sesi B:
BEGIN;
UPDATE lab9.rekening SET saldo = saldo + 50000 WHERE rekening_id = 1;
COMMIT;

### Sesi A:
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
COMMIT;


## Q8: Menguji PHANTOM READ
### Sesi A:
BEGIN;
SELECT * FROM lab9.rekening WHERE saldo >= 1000000;

### Sesi B:
INSERT INTO lab9.rekening (rekening_id, nama, saldo)
VALUES (3, 'Citra', 1500000);
COMMIT;

### Sesi A:
SELECT * FROM lab9.rekening WHERE saldo >= 1000000;
COMMIT;


## Q9: Menguji READ UNCOMMITTED
### Sesi A:
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 1;

### Sesi B:
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
COMMIT;

### Sesi A:
ROLLBACK;


## Q10: Menguji LOST UPDATE
### Sesi A:
BEGIN;
UPDATE lab9.rekening SET saldo = 1850000 WHERE rekening_id = 1;

### Sesi B:
BEGIN;
UPDATE lab9.rekening SET saldo = 1950000 WHERE rekening_id = 1;

### Sesi A:
COMMIT;

### Sesi B:
COMMIT;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;

Hasil: Saldo akhir Rp1.950.000. Perubahan sesi A tertimpa oleh sesi B.


## Q12: Mencegah LOST UPDATE dengan Atomic Update

### Sesi A:
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 10000
WHERE rekening_id = 1 AND saldo >= 10000;


### Sesi B:
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 10000
WHERE rekening_id = 1 AND saldo >= 10000;


### Sesi A:
COMMIT;

### Sesi B:
COMMIT;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;

Hasil: Kedua transaksi mengurangi saldo masing-masing Rp10.000 sehingga total pengurangan Rp20.000. Sesi B menunggu Sesi A melakukan COMMIT, kemudian memperbarui saldo terbaru sehingga tidak terjadi lost update.

## Q13: Mencegah LOST UPDATE dengan SELECT FOR UPDATE

### Sesi A:
BEGIN;
SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1 FOR UPDATE;

UPDATE lab9.rekening SET saldo = saldo - 10000
WHERE rekening_id = 1;

### Sesi B:
BEGIN;
SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1 FOR UPDATE;

### Sesi A:
COMMIT;

### Sesi B:
UPDATE lab9.rekening SET saldo = saldo - 10000
WHERE rekening_id = 1;

COMMIT;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;

Hasil: Sesi B menunggu karena rekening 1 sedang dikunci oleh Sesi A. Setelah Sesi A melakukan COMMIT, Sesi B memperoleh lock dan dapat memperbarui saldo. Kedua transaksi mengurangi saldo masing-masing Rp10.000 sehingga total pengurangan Rp20.000 tanpa terjadi *lost update*.

Q14: Mencegah LOST UPDATE dengan Versioning

###Setup:
ALTER TABLE lab9.rekening
ADD COLUMN IF NOT EXISTS version_no INT DEFAULT 1;

UPDATE lab9.rekening
SET version_no = 1
WHERE rekening_id = 1;

### 11Sesi A:
BEGIN;
SELECT saldo, version_no FROM lab9.rekening
WHERE rekening_id = 1;

### Sesi B:
BEGIN;
SELECT saldo, version_no FROM lab9.rekening
WHERE rekening_id = 1;

### Sesi A:
UPDATE lab9.rekening
SET saldo = saldo - 10000,
    version_no = version_no + 1
WHERE rekening_id = 1 AND version_no = 1;

COMMIT;

### Sesi B:
UPDATE lab9.rekening
SET saldo = saldo - 10000,
    version_no = version_no + 1
WHERE rekening_id = 1 AND version_no = 1;

COMMIT;

Hasil: Sesi A berhasil memperbarui saldo dan menaikkan version_no dari 1 menjadi 2. Sesi B tidak dapat memperbarui data karena versi yang dibaca sebelumnya sudah berubah. Perintah UPDATE pada Sesi B menghasilkan UPDATE 0, sehingga aplikasi dapat mengetahui adanya perubahan data dan mencegah lost update.

Q15: Menguji MVCC dan Snapshot

### Sesi A:
BEGIN;
SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;

### Sesi B:
BEGIN;
UPDATE lab9.rekening
SET saldo = saldo + 50000
WHERE rekening_id = 1;

### Sesi A:
SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;

### Sesi B:
COMMIT;

### Sesi A:
SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;
COMMIT;

Hasil: Pada isolation level READ COMMITTED, Sesi A tetap membaca saldo lama ketika perubahan Sesi B belum di-COMMIT. Setelah Sesi B melakukan COMMIT, SELECT berikutnya pada Sesi A menampilkan saldo terbaru yang bertambah Rp50.000. Hal ini menunjukkan bahwa MVCC memungkinkan pembacaan data tanpa harus menunggu transaksi penulis selesai.

Q16: Mengamati Metadata xmin dan xmax pada PostgreSQL

### Sesi A:
BEGIN;
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;

### Sesi B:
BEGIN;
UPDATE lab9.rekening
SET saldo = saldo + 10000
WHERE rekening_id = 1;
COMMIT;

### Sesi A:
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;
COMMIT;

Hasil: Setelah Sesi B melakukan UPDATE dan COMMIT, nilai xmin pada versi baris terbaru berubah, sedangkan xmax umumnya bernilai 0. Hal ini menunjukkan bahwa PostgreSQL menggunakan MVCC untuk mengelola versi data. xmin dan xmax merupakan metadata transaksi, bukan kolom bisnis biasa, dan tidak cukup digunakan sendiri untuk menentukan status visibilitas baris.

Q17: Mengamati Manfaat MVCC dan VACUUM

### Sesi A:
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;

### Sesi B:
BEGIN;
UPDATE lab9.rekening
SET saldo = saldo + 10000
WHERE rekening_id = 1;

UPDATE lab9.rekening
SET saldo = saldo + 20000
WHERE rekening_id = 1;

COMMIT;

### Sesi A:
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;

Menjalankan VACUUM:
VACUUM VERBOSE lab9.rekening;

Hasil: Setelah Sesi B melakukan UPDATE dan COMMIT, saldo bertambah Rp30.000 dan PostgreSQL membuat versi baris baru melalui MVCC. Perintah VACUUM membantu membersihkan versi baris lama yang sudah tidak diperlukan sehingga penggunaan penyimpanan lebih efisien. VACUUM tidak mengubah saldo maupun data aktif pada tabel.

