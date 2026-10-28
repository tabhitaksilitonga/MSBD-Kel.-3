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

