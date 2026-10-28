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
