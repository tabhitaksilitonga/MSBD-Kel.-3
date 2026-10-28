# Laporan Latihan Kelompok Pertemuan 6

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |
| :--- | :--- | :--- | :--- |
| Tabhita Kristy SIlitonga | 251402023 | Project Manager, Setup Q00, Finalisasi laporan & readme | 277c52c |
| Jevine Jeje Zakarias Simanjuntak | 251402085 | Langkah 2 (Q01-Q04) View & WITH CHECK OPTION, Refleksi A | 2ee4bfd |
| Fadila Lisma Sari | 251402117 | Langkah 3 (Q05-Q08) Materialized View & Concurrent Refresh, Refleksi B | 0d36a6f |
| Qairsya Naurel ein Yaliki | 251402120 | Langkah 4 (Q09-Q13) Trigger Audit Baris & Pernyataan, Refleksi C | 9bb7819 |
| Reynald Alvaro Pasaribu | 251402147 | Langkah 5 & 6 (Q14-Q21) Constraint & Expand-Contract, Refleksi D & E | ed8c976 |

---




### Q6. Non-Repeatable Read pada READ COMMITTED

#### 1. Tujuan
Mengetahui perubahan hasil pembacaan data ketika transaksi lain mengubah dan menyimpan data yang sama.

#### 2. Langkah Percobaan

**Sesi A:**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;
```

Hasil pembacaan pertama menunjukkan saldo Ani sebesar Rp1.100.000.

**Sesi B:**
```sql
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo + 50000
WHERE rekening_id = 1;

COMMIT;
```

**Sesi A:**
```sql
SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;

COMMIT;
```

#### 3. Hasil dan Analisis
Pada pembacaan pertama, saldo Ani adalah Rp1.100.000. Setelah Sesi B menambahkan Rp50.000 dan melakukan COMMIT, pembacaan kedua pada Sesi A menunjukkan Rp1.150.000.

Hal ini terjadi karena READ COMMITTED memungkinkan setiap perintah SELECT melihat data yang sudah di-commit sebelum perintah tersebut dijalankan. Oleh karena itu, hasil pembacaan dalam satu transaksi dapat berubah.

#### 4. Kesimpulan
READ COMMITTED dapat mengalami non-repeatable read karena transaksi yang sama bisa memperoleh hasil pembacaan berbeda setelah transaksi lain melakukan perubahan dan COMMIT.


---

### Q7. Non-Repeatable Read pada REPEATABLE READ

#### 1. Tujuan
Mengetahui apakah REPEATABLE READ dapat mempertahankan hasil pembacaan data selama transaksi berlangsung.

#### 2. Langkah Percobaan

**Sesi A:**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;
```

Hasil pembacaan pertama menunjukkan saldo Ani sebesar Rp1.250.000.

**Sesi B:**
```sql
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo + 50000
WHERE rekening_id = 1;

COMMIT;
```

**Sesi A:**
```sql
SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;

COMMIT;
```

#### 3. Hasil dan Analisis
Sesi A tetap melihat saldo sebesar Rp1.250.000 pada pembacaan kedua, meskipun Sesi B telah mengubah saldo dan melakukan COMMIT.

Setelah transaksi Sesi A selesai, saldo yang tersimpan menjadi Rp1.300.000. Hal ini menunjukkan bahwa REPEATABLE READ menggunakan snapshot data yang konsisten selama transaksi berlangsung.

#### 4. Kesimpulan
REPEATABLE READ menjaga konsistensi hasil pembacaan selama transaksi sehingga perubahan yang dilakukan dan di-commit oleh transaksi lain tidak langsung terlihat dalam snapshot transaksi tersebut.


---

### Q8. Phantom Read pada READ COMMITTED

#### 1. Tujuan
Mengamati perubahan jumlah baris yang dikembalikan oleh query ketika transaksi lain menambahkan data yang memenuhi kondisi pencarian.

#### 2. Langkah Percobaan

**Sesi A:**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT rekening_id, pemilik, saldo
FROM lab9.rekening
WHERE saldo >= 1000000;
```

**Sesi B:**
```sql
BEGIN;

INSERT INTO lab9.rekening
    (rekening_id, pemilik, saldo)
VALUES
    (3, 'Citra', 1500000);

COMMIT;
```

**Sesi A:**
```sql
SELECT rekening_id, pemilik, saldo
FROM lab9.rekening
WHERE saldo >= 1000000;

COMMIT;
```

#### 3. Hasil dan Analisis
Pada query pertama, Sesi A menampilkan rekening yang memenuhi kondisi saldo minimal Rp1.000.000. Setelah Sesi B menambahkan rekening Citra dengan saldo Rp1.500.000 dan melakukan COMMIT, Citra muncul pada hasil query kedua.

Baris baru tersebut merupakan contoh phantom read karena query yang sama menghasilkan tambahan baris akibat perubahan yang dilakukan oleh transaksi lain.

#### 4. Kesimpulan
Pada READ COMMITTED, query yang sama dapat menghasilkan kumpulan baris berbeda dalam satu transaksi. REPEATABLE READ dapat mempertahankan snapshot pembacaan, sedangkan SERIALIZABLE memberikan perlindungan lebih kuat terhadap anomali transaksi.


---

### Q9. Dirty Read pada READ UNCOMMITTED

#### 1. Tujuan
Mengetahui apakah suatu transaksi dapat membaca perubahan data yang belum di-commit oleh transaksi lain.

#### 2. Langkah Percobaan

**Sesi A:**
```sql
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo + 100000
WHERE rekening_id = 1;
```

Perubahan pada Sesi A belum di-commit.

**Sesi B:**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;

COMMIT;
```

**Sesi A:**
```sql
ROLLBACK;

SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;
```

#### 3. Hasil dan Analisis
Sesi B membaca saldo Ani sebesar Rp1.350.000, yaitu nilai terakhir yang sudah di-commit. Perubahan sebesar Rp100.000 dari Sesi A tidak terlihat karena belum di-commit.

Setelah Sesi A menjalankan ROLLBACK, perubahan tersebut dibatalkan dan saldo Ani tetap Rp1.350.000.

Pada PostgreSQL, READ UNCOMMITTED berperilaku sama dengan READ COMMITTED. Oleh karena itu, dirty read tidak terjadi.

#### 4. Kesimpulan
PostgreSQL mencegah dirty read meskipun isolation level yang digunakan adalah READ UNCOMMITTED. Data yang belum di-commit tidak dapat dibaca oleh transaksi lain.


---

### Q10. Lost Update pada READ COMMITTED

#### 1. Tujuan
Menunjukkan bagaimana pembaruan satu transaksi dapat menimpa pembaruan transaksi lain ketika kedua transaksi membaca saldo awal yang sama dan menghitung nilai baru di sisi aplikasi.

#### 2. Langkah Percobaan

Saldo awal Ani yang digunakan dalam percobaan adalah Rp1.750.000.

**Sesi A:**
```sql
BEGIN;

SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;
```

Sesi A membaca saldo Rp1.750.000, kemudian menghitung nilai baru di sisi aplikasi:

Rp1.750.000 + Rp100.000 = Rp1.850.000.

Selanjutnya, Sesi A menjalankan:

```sql
UPDATE lab9.rekening
SET saldo = 1850000
WHERE rekening_id = 1;
```

Sesi A belum melakukan COMMIT.

**Sesi B:**
```sql
BEGIN;

SELECT saldo
FROM lab9.rekening
WHERE rekening_id = 1;
```

Sesi B juga membaca saldo awal Rp1.750.000, kemudian menghitung nilai baru:

Rp1.750.000 + Rp200.000 = Rp1.950.000.

Selanjutnya, Sesi B menjalankan:

```sql
UPDATE lab9.rekening
SET saldo = 1950000
WHERE rekening_id = 1;
```

Perintah UPDATE Sesi B menunggu karena baris rekening sedang dikunci oleh Sesi A.

**Kembali ke Sesi A:**
```sql
COMMIT;
```

Setelah itu, UPDATE pada Sesi B selesai. Sesi B kemudian menjalankan:

```sql
COMMIT;

SELECT rekening_id, pemilik, saldo
FROM lab9.rekening
WHERE rekening_id = 1;
```

#### 3. Hasil dan Analisis
Saldo awal yang dibaca kedua sesi adalah Rp1.750.000. Sesi A menghitung saldo baru menjadi Rp1.850.000, sedangkan Sesi B menghitung saldo baru menjadi Rp1.950.000.

Setelah Sesi A melakukan COMMIT, Sesi B menulis nilai tetap Rp1.950.000. Akibatnya, hasil pembaruan Sesi A tertimpa.

Saldo akhir yang diamati adalah Rp1.950.000. Jika kedua penambahan diterapkan secara berurutan, saldo seharusnya menjadi Rp2.050.000.

#### 4. Kesimpulan
Lost update terjadi ketika transaksi menggunakan nilai lama untuk menghitung nilai baru dan kemudian menimpa hasil pembaruan transaksi lain. Masalah ini dapat dicegah dengan operasi UPDATE atomik, penguncian baris menggunakan SELECT FOR UPDATE, atau optimistic locking.


---

### Q11. Ringkasan Anomali Transaksi

| Anomali | Urutan Kejadian | Isolation Level | Hasil yang Diamati | Cara Mencegah atau Menangani |
|---|---|---|---|---|
| Non-repeatable read (Q6) | Sesi A membaca saldo, Sesi B mengubah saldo dan COMMIT, kemudian Sesi A membaca kembali. | READ COMMITTED | Hasil pembacaan berubah dari Rp1.100.000 menjadi Rp1.150.000. | Gunakan REPEATABLE READ jika pembacaan harus konsisten. |
| Non-repeatable read (Q7) | Sesi A membaca saldo, Sesi B mengubah saldo dan COMMIT, kemudian Sesi A membaca kembali. | REPEATABLE READ | Sesi A tetap melihat Rp1.250.000 pada pembacaan kedua. | Gunakan snapshot transaksi yang konsisten, seperti pada REPEATABLE READ. |
| Phantom read (Q8) | Sesi A menjalankan query, Sesi B menambahkan Citra dan COMMIT, kemudian Sesi A menjalankan query yang sama. | READ COMMITTED | Baris Citra muncul pada hasil query kedua. | Gunakan REPEATABLE READ atau SERIALIZABLE sesuai kebutuhan. |
| Dirty read (Q9) | Sesi A mengubah saldo tanpa COMMIT, lalu Sesi B mencoba membaca perubahan tersebut. | READ UNCOMMITTED | Sesi B tetap membaca nilai terakhir yang sudah di-commit. | PostgreSQL mencegah dirty read pada semua isolation level yang didukung. |
| Lost update (Q10) | Kedua sesi membaca saldo Rp1.750.000, menghitung nilai baru, lalu Sesi B menulis nilai tetap setelah Sesi A COMMIT. | READ COMMITTED | Saldo akhir Rp1.950.000; pembaruan Sesi A tertimpa. | Gunakan UPDATE atomik, SELECT FOR UPDATE, atau optimistic locking. |

#### Kesimpulan Q11
Setiap isolation level memiliki tingkat perlindungan berbeda terhadap anomali transaksi. READ COMMITTED memungkinkan perubahan terlihat pada pembacaan berikutnya, sedangkan REPEATABLE READ mempertahankan snapshot yang konsisten. PostgreSQL mencegah dirty read, tetapi masalah seperti lost update tetap perlu ditangani dengan strategi penguncian atau pembaruan data yang tepat.


---

## Kesimpulan Umum Q6–Q11

Berdasarkan percobaan Q6 sampai Q11, dapat disimpulkan bahwa isolation level berpengaruh terhadap konsistensi data ketika beberapa transaksi berjalan secara bersamaan. READ COMMITTED memungkinkan hasil pembacaan berubah setelah transaksi lain melakukan COMMIT, sedangkan REPEATABLE READ mempertahankan hasil pembacaan dari snapshot transaksi.

Percobaan dirty read menunjukkan bahwa PostgreSQL tidak mengizinkan transaksi membaca perubahan yang belum di-commit. Sementara itu, percobaan lost update menunjukkan bahwa penggunaan nilai tetap yang dihitung dari saldo lama dapat menyebabkan pembaruan transaksi lain tertimpa.

Oleh karena itu, pemilihan isolation level dan penggunaan mekanisme seperti UPDATE atomik, penguncian baris, serta optimistic locking sangat penting untuk menjaga konsistensi data dalam sistem basis data.
