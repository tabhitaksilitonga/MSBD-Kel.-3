# Laporan Latihan Kelompok Pertemuan 11

## Tautan Merge Request Kelompok
https://github.com/tabhitaksilitonga/MSBD-Kel.-3/pull/5

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |
| :--- | :--- | :--- | :--- |
| Tabhita Kristy Silitonga | 251402023 | Project Manager, Langkah 1 (Setup), Langkah 6 (Q25-Q30) Audit & UU PDP, Reflektif E, Finalisasi laporan & readme | 1e9f2aa |
| Jevine Jeje Zakarias Simanjuntak | 251402085 | Langkah 2 (Q01-Q05) Kepemilikan, GRANT & Peran Berlapis, Reflektif A | 08ad838 |
| Fadila Lisma Sari | 251402117 | Langkah 3 (Q06-Q11) Row-Level Security (RLS) Multi-penyewa, Reflektif B | 05c3cd9 |
| Qairsya Naurel ein Yaliki | 251402120 | Langkah 4 (Q12-Q18) Menutup Celah SQL Injection, Reflektif C | 20f10ec |
| Reynald Alvaro Pasaribu | 251402147 | Langkah 5 (Q19-Q24) Enkripsi, Hashing, dan Penyamaran, Reflektif D | 47fa13a |

## Q1-Q30
Perintah, keluaran, dan alasan keputusan

### Q06 – Default Deny
**Perintah:**
> ALTER TABLE lab11.pelanggan
ENABLE ROW LEVEL SECURITY;

BEGIN;
SET LOCAL ROLE app_laporan;

SELECT COUNT(*) AS sebelum_ada_kebijakan
FROM lab11.pelanggan;

COMMIT;

**Keluaran:**
> ALTER TABLE
BEGIN
SET
 sebelum_ada_kebijakan
-----------------------
                     0
(1 row)

COMMIT

**Alasan Keputusan:**
> Pada tahap ini, RLS diaktifkan pada tabel pelanggan untuk membatasi akses terhadap data. Hasil pengujian menunjukkan jumlah data yang bisa dilihat oleh app_laporan adalah 0 karena belum ada policy yang memberikan izin akses. Cara ini dipilih agar akses data secara default ditolak terlebih dahulu sebelum aturan akses dibuat.

### Q07 – Kebijakan Penyewa
**Perintah:**
> CREATE POLICY p_tenant_baca
ON lab11.pelanggan
FOR SELECT
TO app_read, app_write
USING (
    tenant_id = NULLIF(current_setting('app.tenant', true), '')::INT
);

CREATE POLICY p_tenant_tulis
ON lab11.pelanggan
FOR ALL
TO app_write
USING (
    tenant_id = NULLIF(current_setting('app.tenant', true), '')::INT
)
WITH CHECK (
    tenant_id = NULLIF(current_setting('app.tenant', true), '')::INT
);

**Keluaran:**
>CREATE POLICY
 CREATE POLICY

**Alasan Keputusan:**
> Pada tahap ini dibuat dua policy untuk mengatur akses berdasarkan tenant_id. Policy pertama digunakan untuk membatasi data yang boleh dibaca, sedangkan policy kedua mengatur operasi penambahan, perubahan, dan penghapusan data. Penggunaan current_setting('app.tenant') dipilih agar akses data mengikuti tenant yang sedang digunakan oleh aplikasi.

### Q08 – Uji Positif dan Negatif
**Perintah:**
> BEGIN;

SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

SELECT COUNT(*) AS terlihat_tenant1
FROM lab11.pelanggan;

SELECT COUNT(*) AS harus_nol
FROM lab11.pelanggan
WHERE tenant_id = 2;

COMMIT;

**Keluaran:**
> terlihat_tenant1
------------------
            10000
(1 row)

 harus_nol
-----------
         0
(1 row)

**Alasan Keputusan:**
> Pengujian ini dilakukan untuk memastikan bahwa setiap tenant hanya bisa melihat data miliknya sendiri. Hasilnya menunjukkan tenant 1 dapat melihat 10.000 data pelanggan, sedangkan ketika mencoba melihat data tenant 2 hasilnya 0. Hal ini membuktikan bahwa policy RLS berhasil membatasi akses antar-tenant.

### Q09 – FORCE RLS dan BYPASSRLS
**Perintah:**
> -- Menguji akses pemilik tabel sebelum FORCE RLS
BEGIN;
SET LOCAL ROLE skema_owner;

SELECT COUNT(*) AS owner_sebelum_force
FROM lab11.pelanggan;

COMMIT;

-- Mengaktifkan FORCE RLS
ALTER TABLE lab11.pelanggan
FORCE ROW LEVEL SECURITY;

-- Menguji kembali akses pemilik tabel
BEGIN;
SET LOCAL ROLE skema_owner;

SELECT COUNT(*) AS owner_setelah_force
FROM lab11.pelanggan;

COMMIT;

-- Memberikan hak baca kepada app_analitik
GRANT pg_read_all_data TO app_analitik;

-- Menguji tanpa BYPASSRLS
BEGIN;
SET LOCAL ROLE app_analitik;

SELECT COUNT(*) AS analitik_tanpa_bypass
FROM lab11.pelanggan;

COMMIT;

-- Mengaktifkan BYPASSRLS
ALTER ROLE app_analitik BYPASSRLS;

-- Menguji dengan BYPASSRLS
BEGIN;
SET LOCAL ROLE app_analitik;

SELECT COUNT(*) AS analitik_dengan_bypass
FROM lab11.pelanggan;

COMMIT;

-- Mengembalikan atribut BYPASSRLS
ALTER ROLE app_analitik NOBYPASSRLS;

**Keluaran:**
>owner_sebelum_force
--------------------
               30000

owner_setelah_force
--------------------
                   0

analitik_tanpa_bypass
----------------------
                     0

analitik_dengan_bypass
-----------------------
                 30000

**Alasan Keputusan:**
> Pengujian ini dilakukan untuk melihat apakah pemilik tabel dan role tertentu bisa melewati aturan RLS. Sebelum FORCE ROW LEVEL SECURITY diaktifkan, pemilik tabel masih bisa melihat seluruh 30.000 data pelanggan. Setelah FORCE diaktifkan, aksesnya menjadi 0 karena pemilik tabel ikut terkena aturan RLS. Pengujian juga menunjukkan bahwa pemberian pg_read_all_data saja tidak membuat role bisa melewati RLS. Namun, setelah atribut BYPASSRLS diberikan, role app_analitik dapat melihat seluruh data. Oleh karena itu, hak BYPASSRLS perlu dibatasi hanya untuk role yang benar-benar membutuhkannya.

### Q10 – Kolam Koneksi (Connection Pool)
**Perintah:**
> BEGIN;

SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

SELECT
    current_setting('app.tenant', true) AS tenant_aktif,
    COUNT(*) AS jumlah_pelanggan
FROM lab11.pelanggan;

COMMIT;

SELECT
    current_setting('app.tenant', true) AS konteks_setelah_commit;

**Keluaran:**
>tenant_aktif | jumlah_pelanggan
--------------+------------------
 1            |            10000
(1 row)

 konteks_setelah_commit
------------------------

(1 row)

**Alasan Keputusan:**
> Pada tahap ini dilakukan simulasi penggunaan koneksi database secara bergantian oleh beberapa pengguna. SET LOCAL dipilih karena pengaturan tenant hanya berlaku selama transaksi berlangsung. Setelah transaksi selesai dengan COMMIT, konteks tenant kembali kosong sehingga tidak tertinggal dan berpotensi digunakan oleh pengguna berikutnya. Cara ini membantu mencegah kebocoran data antar-tenant pada penggunaan connection pool.

### Q11 – Tiga Celah Keamanan RLS
**Perintah:**
> SELECT
    c.relname AS nama_tabel,
    c.relrowsecurity AS rls_aktif,
    c.relforcerowsecurity AS force_rls_aktif
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'lab11'
  AND c.relname = 'pelanggan';

**Keluaran:**
>nama_tabel | rls_aktif | force_rls_aktif
------------+-----------+-----------------
 pelanggan  | t         | t
(1 row)

**Alasan Keputusan:**
>Pada tahap ini dilakukan identifikasi terhadap tiga kondisi yang dapat menyebabkan keamanan RLS menjadi lemah, yaitu:
1. Pemilik tabel dapat melewati RLS jika FORCE ROW LEVEL SECURITY belum diaktifkan. Solusinya adalah mengaktifkan FORCE agar pemilik tabel ikut terkena aturan RLS.
2. Role yang memiliki atribut BYPASSRLS dapat melihat data tanpa mengikuti policy RLS. Solusinya adalah membatasi pemberian atribut tersebut kepada role aplikasi.
3. Konteks tenant dapat tertinggal atau dimanipulasi jika pengaturan koneksi tidak dilakukan dengan benar. Solusinya adalah menggunakan SET LOCAL dalam transaksi dan memastikan identitas tenant berasal dari proses autentikasi yang tepercaya.
Hasil pemeriksaan menunjukkan bahwa RLS dan FORCE RLS pada tabel pelanggan sudah aktif. Selain itu, pengujian pada Q09 dan Q10 juga menjadi bukti bahwa celah terkait pemilik tabel, BYPASSRLS, dan konteks tenant sudah diuji.

### Q19 – Hashing vs Enkripsi
**Perintah:**
> SELECT
    crypt('password123', gen_salt('bf', 8)) AS hash_pertama,
    crypt('password123', gen_salt('bf', 8)) AS hash_kedua;

**Keluaran:**
> latihan=# SELECT
    crypt('password123', gen_salt('bf', 8)) AS hash_1,
    crypt('password123', gen_salt('bf', 8)) AS hash_2;
                            hash_1                            |                            hash_2                            
--------------------------------------------------------------+--------------------------------------------------------------
 $2a$08$YPzb48EhD5Den7Dtrcg0teko5PQ1udMDw70JY3LLozj8U0l1pQhJK | $2a$08$Uk/yg3RETLoztkYyVY8mTu6pQM.HryFqK2yiBq5uyBG3OwE5pDAom
(1 row)

**Alasan Keputusan:**
>Pada tahap ini dilakukan hashing kata sandi menggunakan algoritma bcrypt. Penggunaan salt membuat hasil hash dari kata sandi yang sama menjadi berbeda sehingga mengurangi risiko serangan menggunakan tabel hash yang sudah tersedia (rainbow table).

### Q20 – Pengukuran Biaya Kerja
**Perintah:**
> EXPLAIN ANALYZE
SELECT crypt('password123', gen_salt('bf', 6));

EXPLAIN ANALYZE
SELECT crypt('password123', gen_salt('bf', 10));

EXPLAIN ANALYZE
SELECT md5('password123');

**Keluaran:**
> Bcrypt cost 6:
Execution Time: 6.444 ms

Bcrypt cost 10:
Execution Time: 60.383 ms

MD5:
Execution Time: 0.036 ms

**Alasan Keputusan:**
> Pada tahap ini dilakukan pengukuran waktu eksekusi bcrypt dengan cost 6, bcrypt dengan cost 10, dan MD5. Pengujian ini bertujuan membandingkan biaya komputasi masing-masing metode. Bcrypt dipilih untuk hashing kata sandi karena prosesnya lebih lambat sehingga lebih sulit diserang menggunakan brute force.

### Q21 – Enkripsi Kolom Rekening
**Perintah:**
> SET app.kunci_kolom = 'kunci-lab11-jangan-dipakai-di-produksi';

ALTER TABLE lab11.pelanggan
ADD COLUMN rekening_enc BYTEA;

UPDATE lab11.pelanggan
SET rekening_enc = pgp_sym_encrypt(
    rekening,
    current_setting('app.kunci_kolom')
)
WHERE id <= 1000;

SELECT pgp_sym_decrypt(
    rekening_enc,
    current_setting('app.kunci_kolom')
)
FROM lab11.pelanggan
WHERE id = 1;

SELECT
    pgp_sym_encrypt('x', 'k') =
    pgp_sym_encrypt('x', 'k') AS sama;

**Keluaran:**
> Hasil pengujian pada pelanggan dengan ID 3 menunjukkan bahwa sudah_terenkripsi bernilai true dan hasil dekripsi sama dengan rekening asli, yaitu 12345678900003.

Berdasarkan query COUNT(*), terdapat tepat 1.000 baris yang berhasil dienkripsi. Pengujian perbandingan ciphertext menghasilkan false, yang menunjukkan bahwa dua proses enkripsi terhadap plaintext dan kunci yang sama menghasilkan ciphertext berbeda.

**Alasan Keputusan:**
> Pada tahap ini dilakukan enkripsi kolom rekening menggunakan pgp_sym_encrypt() dengan kunci simetris. Enkripsi dipilih karena data rekening perlu dikembalikan ke bentuk aslinya ketika dibutuhkan. Berbeda dengan hashing, enkripsi memungkinkan proses dekripsi menggunakan kunci yang sesuai.

### Q22 – Pemeriksaan Kebocoran Kunci
**Perintah:**
> SELECT
    pid,
    usename,
    query,
    state
FROM pg_stat_activity
WHERE datname = current_database();

**Keluaran:**
> Berdasarkan hasil pengujian, sesi pertama berhasil membaca kunci enkripsi melalui current_setting('app.kunci_kolom'), yaitu kunci-lab11-jangan-dipakai-di-produksi. Sesi kedua dapat melihat aktivitas dan teks query sesi pertama melalui pg_stat_activity, tetapi nilai kunci tidak muncul langsung pada hasil pemeriksaan yang dilakukan. Hal ini menunjukkan bahwa konfigurasi kunci bersifat khusus untuk sesi PostgreSQL yang menyimpannya.

**Alasan Keputusan:**
> Pada tahap ini dilakukan pemeriksaan aktivitas database melalui pg_stat_activity untuk mengetahui apakah query enkripsi menampilkan kunci atau data dalam bentuk teks asli. Pemeriksaan ini penting karena kunci yang terekspos dapat dimanfaatkan pihak tidak berwenang untuk membuka data terenkripsi.

### Q23 – Penyamaran Data (Data Masking)
**Perintah:**
> REVOKE pg_read_all_data FROM app_analitik;

CREATE VIEW lab11.v_pelanggan_samar
WITH (security_barrier = true) AS
SELECT
    id,
    tenant_id,
    left(nama, 1) || repeat('*', greatest(length(nama)-1, 1)) AS nama,
    'xxxxxxxxxxxx' || right(nik, 4) AS nik,
    regexp_replace(surel, '^[^@]+', '****') AS surel,
    date_trunc('year', lahir)::date AS lahir_tahun,
    kota,
    round(saldo, -5) AS saldo_bulat
FROM lab11.pelanggan;

REVOKE ALL ON lab11.pelanggan FROM app_analitik;

GRANT SELECT ON lab11.v_pelanggan_samar TO app_analitik;

**Keluaran:**
> latihan=> SELECT * FROM lab11.pelanggan LIMIT 5;
ERROR:  permission denied for table pelanggan
latihan=> SELECT * FROM lab11.v_pelanggan_samar LIMIT 5;
  id  | nama |     nik      | surel | tahun_lahir |  kota   | saldo 
------+------+--------------+-------+-------------+---------+-------
 1001 | P*** | 1234******** | us*** | 1972-01-01  | Jakarta |  1000
 1002 | P*** | 1234******** | us*** | 1972-01-01  | Medan   |  2000
 1003 | P*** | 1234******** | us*** | 1972-01-01  | Jakarta |  3000
 1004 | P*** | 1234******** | us*** | 1972-01-01  | Medan   |  4000
 1005 | P*** | 1234******** | us*** | 1972-01-01  | Jakarta |  5000
(5 rows)

Pengujian menggunakan akun app_analitik menunjukkan bahwa akses langsung ke tabel lab11.pelanggan ditolak dengan pesan permission denied for table pelanggan. Namun, akses ke view lab11.v_pelanggan_samar berhasil dan menampilkan data yang telah disamarkan, seperti nama menjadi P***, NIK menjadi 1234********, surel menjadi us***, tanggal lahir ditampilkan berdasarkan tahun, serta saldo dibulatkan ke ribuan terdekat.

**Alasan Keputusan:**
> Pada tahap ini dibuat VIEW untuk menampilkan data pelanggan dalam bentuk tersamar. Data seperti nama, NIK, dan surel disamarkan agar analis tetap dapat menggunakan informasi yang diperlukan tanpa melihat seluruh data sensitif. Hak akses diberikan hanya pada VIEW, bukan pada tabel aslinya.

### Q24 – Identifikasi Ulang Data
**Perintah:**
> SELECT COUNT(*) AS kombinasi_asli
FROM (
    SELECT DISTINCT kota, lahir
    FROM lab11.pelanggan
) AS data_asli;

SELECT COUNT(*) AS kombinasi_generalisasi
FROM (
    SELECT DISTINCT
        kota,
        date_trunc('year', lahir)::date AS tahun_lahir
    FROM lab11.pelanggan
) AS data_generalisasi;

**Keluaran:**
> Dari total 30.000 pelanggan, ditemukan 20.000 kombinasi unik kota dan tanggal lahir. Setelah tanggal lahir digeneralisasi menjadi tahun lahir, jumlah kombinasi unik berkurang menjadi 110. Persentase pengurangan kombinasi unik mencapai 99,45%. Pengujian tambahan juga menemukan kombinasi kota dan tanggal lahir yang hanya dimiliki satu pelanggan.

**Alasan Keputusan:**
> Pada tahap ini dilakukan perbandingan jumlah kombinasi unik kota dan tanggal lahir sebelum dan sesudah generalisasi menjadi tahun kelahiran. Generalisasi dipilih untuk mengurangi detail informasi pribadi sehingga risiko identifikasi ulang terhadap pelanggan dapat dikurangi.

## Refleksi A-E

### Refleksi A

**1. Pada Q1, hak biasa bisa dicabut dari pemilik, tetapi risikonya tetap ada. Jelaskan dari data mengapa “mencabut hak” bukan jalan keluar untuk keluhan K1, dan apa yang menjadi jalan keluarnya**
> Perintah `REVOKE` ga bisa menyelesaikan masalah kebocoran data lintas penyewa karena dua alasan dari percobaan kita:
Pertama, `REVOKE` dan `GRANT` hanya mengatur izin di level tabel, bukan per baris. pdahal di `q00_setup.sql`, data dari ketiga penyewa (total 30.000 baris, masing-masing 10.000 baris) digabung dlm satu tabel `lab11.pelanggan`. Kalau izinnya dicabut, aplikasi malah tidak bisa mengakses data penyewanya sendiri, tapi kalau diberikan, aplikasi justru bisa melihat seluruh 30.000 baris milik penyewa lain.
Kedua, dari `q01_hak_pemilik.sql` terbukti kalau peran pemilik tabel bisa memberikan kembali hak `UPDATE` yg sudah dicabut menggunakan perintah `GRANT` ke dirinya sendiri. Jadi, mencabut hak ga akan mempan kalau koneksi masih memakai akun pemilik.
Jalan keluarnya: aplikasi ga boleh login sebagai pemilik (`skema_owner` diset `NOLOGIN`) dan wajib memakai peran terbatas seperti `app_laporan` atau `app_portal`. Selain itu, isolasi datanya harus dikunci di level baris memakai Row-Level Security dengan filter `tenant_id`, biar masing-masing penyewa otomatis hanya bisa melihat dan mengubah 10.000 baris datanya sendiri.

### Reflektif B

**Dengan RLS aktif, apakah penyaring WHERE tenant_id di aplikasi masih perlu ditulis? Jelaskan tugas berbeda yang diemban keduanya, dengan menyebut rencana eksekusi.**
> Menurut saya, meskipun RLS sudah diterapkan, aplikasi tetap perlu menambahkan `WHERE tenant_id = ...` pada query SQL. Hal ini karena RLS dan WHERE memiliki fungsi yang berbeda. RLS digunakan untuk membatasi akses data di tingkat database supaya setiap tenant hanya bisa melihat data miliknya sendiri. Sedangkan `WHERE tenant_id` digunakan untuk mengambil data sesuai kebutuhan aplikasi.
Selain itu, penggunaan `WHERE tenant_id` juga bisa membantu proses pencarian data menjadi lebih efisien, terutama jika kolom tenant_id sudah memiliki indeks. Hal ini dapat dilihat melalui execution plan menggunakan perintah EXPLAIN untuk mengetahui bagaimana PostgreSQL menjalankan query tersebut.
Jadi, menurut saya keduanya tetap diperlukan karena RLS berfungsi sebagai pengaman data, sedangkan WHERE membantu aplikasi mengambil data yang dibutuhkan dengan lebih terarah. Dengan begitu, keamanan data tetap terjaga dan proses pengambilan data juga bisa lebih optimal.

### Reflektif C

Dari keempat lapis pertahanan pada Langkah 4, **satu-satunya lapis yang benar-benar menghapus sebab masalah (akar penyebab SQL injection) adalah penggunaan *parameterized query* (kueri berparameter) yang dilengkapi daftar putih tertutup (*allowlist*) untuk pengenal SQL (Q15–Q16)**. Mekanisme ini memisahkan secara struktural antara saluran kompilasi perintah SQL dengan saluran pengiriman nilai data, sehingga masukan pengguna tidak akan pernah ditafsirkan sebagai instruksi yang mengubah struktur kueri.

Sementara itu, tiga lapis pertahanan lainnya berperan sebagai **pertahanan berlapis (*defense in depth*) untuk membatasi dampak (*blast radius*) dan mendeteksi serangan** apabila celah di kode aplikasi tetap lolos:

1. **Prinsip Hak Minimum Per Tabel (*Least Privilege*, bukti Q14):** Dengan membatasi koneksi aplikasi hanya pada peran baca (`app_laporan` sebagai anggota `app_read`), penyerang yang berhasil menyuntikkan payload tetap tidak dapat mengubah, menambah, atau menghapus data karena tidak memiliki hak `INSERT`, `UPDATE`, `DELETE`, maupun `DDL`.
2. **Row-Level Security / Isolasi Penyewa (RLS, bukti Q14):** Saat payload injeksi `22' OR '1'='1' --` dijalankan melalui koneksi `app_laporan`, kebijakan RLS menahan kebocoran data hanya pada penyewa aktif yang terikat pada sesi tersebut (maksimal 10.000 baris penyewa 1, bukan seluruh 30.000 baris lintas penyewa).
3. **Batas Waktu Eksekusi (*Statement Timeout*, bukti Q18):** Pemasangan `ALTER ROLE app_portal SET statement_timeout = '5s';` mencegah penahanan sumber daya basis data sekaligus membuat percobaan *time-based blind SQL injection* (`pg_sleep`) langsung terputus pada detik ke-5 dan tercatat mencolok di log server dengan `SQLSTATE 57014` (`ERROR: canceling statement due to statement timeout`).

### Reflektif D
**Sebuah tim menyatakan basis datanya aman karena semua kolom peka sudah dienkripsi. Sebutkan dua ancaman yang tetap terbuka dan satu risiko operasional enkripsi kolom, masing-masing dengan bukti dari Q21–Q24.**
> Meskipun semua kolom sensitif sudah dienkripsi, masih terdapat ancaman kebocoran kunci enkripsi yang dapat membuat pihak tidak berwenang membaca data asli, seperti yang diuji pada Q21 dan Q22. Selain itu, data yang sudah disamarkan masih berpotensi mengungkap identitas seseorang melalui kombinasi informasi seperti kota dan tanggal lahir, sebagaimana dibuktikan pada Q23 dan Q24. Risiko operasional lainnya adalah kehilangan kunci enkripsi, sehingga data yang sudah dienkripsi tidak dapat didekripsi kembali. Oleh karena itu, enkripsi harus disertai perlindungan kunci dan penyamaran data agar keamanan informasi lebih terjamin. 

### Reflektif E
**Jejak audit memuat NIK lama di nilai_lama. Jelaskan ketegangan antara kewajiban merekam pemrosesan (Pasal 31) dan kewajiban menghapus data (Pasal 43), lalu usulkan satu penyelesaian yang dapat Anda pertahankan di hadapan pemeriksa.**
> Ketegangan terjadi karena Pasal 43 UU PDP mewajibkan kita menghapus data pribadi secara tuntas (termasuk yang ada di salinan) saat ada permintaan. Namun, Pasal 31 mewajibkan kita merekam seluruh aktivitas pemrosesan. Ketika kita menjalankan perintah DELETE pada tabel utama, aktivitas tersebut terekam oleh trigger dan masuk ke tabel jejak_audit. Imbasnya, data sensitif seperti NIK pada nilai_lama justru tersimpan kembali dan masih "hidup" di dalam log audit. Jadi karena itu, kami akan menerapkan Kebijakan Retensi Data yang tertulis secara formal. Log audit tidak boleh diubah atau dihapus secara manual per baris karena akan merusak integritas audit/pertanggungjawaban. Sebagai jalan tengahnya, NIK tersebut akan tetap berada di log audit sesuai jadwal masa simpan (misalnya 1 tahun), dan setelah masa retensinya habis/kedaluwarsa, seluruh log pada periode tersebut akan dimusnahkan secara otomatis oleh sistem.

## Peta Tiket #1134 ke UU PDP
| Keluhan | Pasal relevan | Kontrol teknis pencegah | Bukti |
| K1: Aplikasi login sebagai pemilik tabel, lalu salah HAPUS. | Pasal 57 (Sanksi & keamanan) | Peran berlapis, cabut akses login dari pemilik tabel. | Q01 & Q05 |
| K2: Penyewa A membaca penyewa B karena aplikasi lupa WHERE. | Pasal 57 (Kerahasiaan/Akses tidak sah) | RLS (Row-Level Security) dengan FORCE dan manajemen konteks SET LOCAL. | Q09 & Q10 |
| K3: Kotak pencarian kebobolan SQL Injection. | Pasal 46 (Pemberitahuan kebocoran) | Kueri Berparameter dan Allowlist (Daftar Putih). | Q15 & Q16 |
| K4: Backup rahasia dipindah ke flashdisk dengan teks biasa. | Pasal 57 (Keamanan & Kerahasiaan) | Penyamaran (Data Masking) salinan & Enkripsi pada tabel. | Q21 & Q23 |
| K5: Permintaan hapus tidak tuntas, data hidup di cadangan. | Pasal 8 & 43 (Hak subjek menghapus data) | Jadwal retensi log, permintaan hapus sebagai antrean data. | Q28 & Q29 |

## Pernyataan Etika
Disetujui secara digital oleh seluruh anggota kelompok 3: Tabhita Kristy Silitonga, Jevine Jeje Zakarias Simanjuntak, Fadila Lisma Sari, Qairsya Naurel ein Yaliki, Reynald Alvaro Pasaribu.

## Penggunaan AI dan Verifikasi
**Penggunaan AI:**
Selama pengerjaan tugas kelompok ini, kami menggunakan bantuan AI untuk:
1. Membantu *troubleshooting* terminal saat fase persiapan (Langkah 1), seperti menangani *error* pembuatan direktori di dalam kontainer Docker dan melacak nama jaringan Docker yang tidak terdeteksi.
2. Menyusun ulang (*reverse-engineering*) kode skrip awal (`docker-compose.lab11.yml`, `lab11_setup.sql`, dan `rentan.py`) berdasarkan parameter di modul PDF, dikarenakan adanya kendala teknis pada tautan unduhan *file* di e-learning.
3. Membantu memberikan referensi struktur sintaks SQL pada Langkah 6 (Q25-Q29) serta bertukar pikiran dalam menyusun draf argumen analisis untuk bagian Reflektif dan pemetaan UU PDP.

**Verifikasi:**
Meskipun menggunakan bantuan AI, seluruh perintah SQL dan kode Python telah diketik, dieksekusi, dan diuji coba secara mandiri oleh setiap anggota kelompok di dalam kontainer `lab11` lokal masing-masing yang berjalan pada jaringan tertutup. Seluruh *output* kueri, angka baris data, dan hasil tangkapan layar yang dilampirkan adalah keluaran nyata dari basis data kami. Kami telah memeriksa kesesuaian logika setiap jawaban dengan materi presentasi dosen dan memahami sepenuhnya seluruh keputusan serta alternatif yang kami tuliskan.