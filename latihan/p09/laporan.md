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

### Q12. Mencegah Lost Update dengan Atomic Update

#### 1. Tujuan

Menguji penggunaan pembaruan atomik untuk mencegah lost update ketika dua transaksi mengubah saldo rekening yang sama.

#### 2. Langkah Percobaan

**Sesi A:**

```
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo - 10000
WHERE rekening_id = 1 AND saldo >= 10000;
```

**Sesi B:**

```
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo - 10000
WHERE rekening_id = 1 AND saldo >= 10000;
```

**Kembali ke Sesi A:**

```
COMMIT;
```

**Sesi B:**

```
COMMIT;

SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;
```

#### 3. Hasil dan Analisis

Sesi A berhasil menjalankan pembaruan saldo dengan respons `UPDATE 1`. Pada mekanisme pembaruan atomik, Sesi B menunggu apabila Sesi A masih memegang lock pada rekening yang sama. Setelah lock dilepaskan, PostgreSQL melanjutkan pembaruan menggunakan saldo terbaru.

Dengan kedua pembaruan berhasil, total pengurangan saldo adalah Rp20.000. Penggunaan operasi atomik memastikan kedua pengurangan diterapkan tanpa menimpa perubahan sebelumnya.

#### 4. Kesimpulan

Atomic update mencegah lost update karena perhitungan saldo dilakukan langsung berdasarkan nilai terbaru di database, bukan menggunakan nilai lama yang sebelumnya dibaca aplikasi.

---

### Q13. Mencegah Lost Update dengan SELECT FOR UPDATE

#### 1. Tujuan

Menguji penggunaan SELECT FOR UPDATE untuk mengunci baris rekening agar transaksi lain tidak dapat mengubah data yang sama secara bersamaan.

#### 2. Langkah Percobaan

**Sesi A:**

```
BEGIN;

SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1 FOR UPDATE;

UPDATE lab9.rekening
SET saldo = saldo - 10000
WHERE rekening_id = 1;
```

**Sesi B:**

```
BEGIN;

SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1 FOR UPDATE;
```

**Kembali ke Sesi A:**

```
COMMIT;
```

**Sesi B:**

```
UPDATE lab9.rekening
SET saldo = saldo - 10000
WHERE rekening_id = 1;

COMMIT;

SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;
```

#### 3. Hasil dan Analisis

Sesi A menggunakan SELECT FOR UPDATE untuk mengunci rekening 1 sebelum melakukan perubahan saldo. Ketika Sesi B meminta lock pada baris yang sama, permintaan tersebut tertahan sampai Sesi A menyelesaikan transaksi.

Setelah Sesi A melakukan COMMIT, Sesi B memperoleh lock dan dapat melanjutkan pembaruan. Pengurangan saldo sebesar Rp10.000 pada masing-masing transaksi dapat diterapkan secara berurutan tanpa saling menimpa.

#### 4. Kesimpulan

SELECT FOR UPDATE mencegah lost update dengan mengatur akses terhadap baris yang sama. Transaksi kedua harus menunggu sampai transaksi pertama selesai sebelum melakukan pembaruan.

---

### Q14. Mencegah Lost Update dengan Versioning

#### 1. Tujuan

Menguji optimistic locking menggunakan kolom version_no untuk mendeteksi perubahan data yang dilakukan oleh transaksi lain.

#### 2. Langkah Percobaan

**Setup:**

```
ALTER TABLE lab9.rekening
ADD COLUMN IF NOT EXISTS version_no INT DEFAULT 1;

UPDATE lab9.rekening
SET version_no = 1
WHERE rekening_id = 1;
```

**Sesi A:**

```
BEGIN;

SELECT saldo, version_no
FROM lab9.rekening
WHERE rekening_id = 1;
```

**Sesi B:**

```
BEGIN;

SELECT saldo, version_no
FROM lab9.rekening
WHERE rekening_id = 1;
```

**Sesi A:**

```
UPDATE lab9.rekening
SET saldo = saldo - 10000,
    version_no = version_no + 1
WHERE rekening_id = 1 AND version_no = 1;

COMMIT;
```

**Sesi B:**

```
UPDATE lab9.rekening
SET saldo = saldo - 10000,
    version_no = version_no + 1
WHERE rekening_id = 1 AND version_no = 1;

COMMIT;
```

**Cek Hasil:**

```
SELECT rekening_id, saldo, version_no
FROM lab9.rekening
WHERE rekening_id = 1;
```

#### 3. Hasil dan Analisis

Kedua sesi membaca version_no bernilai 1. Sesi A melakukan pembaruan terlebih dahulu sehingga saldo berkurang Rp10.000 dan version_no meningkat menjadi 2.

Ketika Sesi B mencoba memperbarui data dengan kondisi version_no = 1, PostgreSQL tidak menemukan baris yang memenuhi syarat tersebut. Perintah UPDATE menghasilkan `UPDATE 0`, sehingga pembaruan kedua tidak dilakukan.

Mekanisme ini memungkinkan aplikasi mengetahui bahwa data telah berubah sejak pembacaan awal.

#### 4. Kesimpulan

Versioning dapat mencegah lost update dengan memeriksa kesesuaian versi sebelum memperbarui data. Jika versi berubah, aplikasi dapat mendeteksi konflik dan melakukan pembacaan ulang sebelum mencoba transaksi kembali.

---

### Q15. Menguji MVCC dan Snapshot

#### 1. Tujuan

Mengamati bagaimana MVCC memungkinkan transaksi membaca data ketika transaksi lain sedang melakukan perubahan yang belum di-commit.

#### 2. Langkah Percobaan

**Sesi A:**

```
BEGIN;

SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;
```

**Sesi B:**

```
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo + 50000
WHERE rekening_id = 1;
```

**Sesi A:**

```
SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;
```

**Sesi B:**

```
COMMIT;
```

**Sesi A:**

```
SELECT saldo FROM lab9.rekening
WHERE rekening_id = 1;

COMMIT;
```

#### 3. Hasil dan Analisis

Pada isolation level READ COMMITTED, Sesi A tetap membaca saldo lama ketika perubahan Sesi B belum di-commit. Pembacaan tersebut tidak terhalang meskipun Sesi B sedang memperbarui baris yang sama.

Setelah Sesi B melakukan COMMIT, pembacaan berikutnya pada Sesi A menampilkan saldo yang sudah bertambah Rp50.000. Perubahan ini menunjukkan bahwa setiap perintah SELECT pada READ COMMITTED menggunakan snapshot yang dapat berbeda.

MVCC memungkinkan PostgreSQL menyediakan versi data yang sesuai untuk transaksi pembaca tanpa selalu menunggu transaksi penulis selesai.

#### 4. Kesimpulan

MVCC membantu meningkatkan konkurensi dengan memungkinkan transaksi membaca data berdasarkan snapshot. Pada READ COMMITTED, perubahan transaksi lain mulai terlihat setelah COMMIT dan pada pembacaan berikutnya.

---

### Q16. Mengamati Metadata xmin dan xmax

#### 1. Tujuan

Mengamati perubahan metadata transaksi xmin dan xmax pada PostgreSQL setelah suatu baris diperbarui.

#### 2. Langkah Percobaan

**Sesi A:**

```
BEGIN;

SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;
```

**Sesi B:**

```
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo + 10000
WHERE rekening_id = 1;

COMMIT;
```

**Sesi A:**

```
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;

COMMIT;
```

**Cek Hasil:**

```
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;
```

#### 3. Hasil dan Analisis

Setelah Sesi B melakukan UPDATE dan COMMIT, PostgreSQL membuat versi baris baru sehingga nilai xmin pada versi terbaru berubah. Nilai xmax pada versi terbaru umumnya bernilai 0.

Pada READ COMMITTED, Sesi A dapat membaca versi terbaru setelah perubahan Sesi B di-commit. Metadata xmin menunjukkan transaksi yang membuat versi baris, sedangkan xmax berkaitan dengan transaksi yang menghapus, memperbarui, atau mengunci baris tersebut.

Kedua nilai ini merupakan metadata internal PostgreSQL dan bukan bagian dari data bisnis rekening.

#### 4. Kesimpulan

Metadata xmin dan xmax digunakan PostgreSQL untuk membantu mengelola versi baris dalam MVCC. Namun, keduanya tidak cukup digunakan sendiri untuk menentukan seluruh status visibilitas suatu baris.

---

### Q17. Mengamati Manfaat MVCC dan VACUUM

#### 1. Tujuan

Memahami manfaat MVCC dalam pengelolaan versi data serta fungsi VACUUM untuk membersihkan versi baris lama yang sudah tidak diperlukan.

#### 2. Langkah Percobaan

**Sesi A:**

```
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;
```

**Sesi B:**

```
BEGIN;

UPDATE lab9.rekening
SET saldo = saldo + 10000
WHERE rekening_id = 1;

UPDATE lab9.rekening
SET saldo = saldo + 20000
WHERE rekening_id = 1;

COMMIT;
```

**Sesi A:**

```
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;
```

**Menjalankan VACUUM:**

```
VACUUM VERBOSE lab9.rekening;
```

**Cek Hasil:**

```
SELECT rekening_id, pemilik, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;
```

#### 3. Hasil dan Analisis

Dua perintah UPDATE pada Sesi B menambah saldo sebesar Rp10.000 dan Rp20.000, sehingga total penambahan menjadi Rp30.000. PostgreSQL membuat versi baris baru untuk mendukung mekanisme MVCC.

Perintah VACUUM digunakan untuk membersihkan versi baris lama yang sudah tidak diperlukan oleh transaksi aktif. Proses ini membantu mengurangi penumpukan data yang tidak terpakai tanpa mengubah saldo pada baris aktif.

VACUUM juga membantu menjaga efisiensi penyimpanan dan mendukung kinerja database dalam jangka panjang.

#### 4. Kesimpulan

MVCC memungkinkan transaksi berjalan bersamaan tanpa selalu saling menghalangi. VACUUM diperlukan untuk mengelola versi baris lama agar penggunaan penyimpanan tetap efisien dan kinerja PostgreSQL terjaga.

---

## Kesimpulan Umum Q12–Q17

Pengujian Q12–Q17 membahas tiga mekanisme pencegahan lost update, yaitu atomic update, SELECT FOR UPDATE, dan optimistic locking menggunakan versioning. Ketiganya memiliki pendekatan berbeda dalam menjaga konsistensi perubahan data ketika beberapa transaksi mengakses rekening yang sama.

MVCC memungkinkan PostgreSQL mengelola beberapa versi baris sehingga transaksi pembaca tidak selalu terhalang oleh transaksi penulis. Metadata xmin dan xmax membantu pengelolaan versi tersebut, sedangkan VACUUM membersihkan versi lama yang sudah tidak diperlukan.

Pemilihan mekanisme transaksi yang tepat dapat membantu menjaga konsistensi data dan mengurangi masalah konkurensi dalam sistem basis data.
