# Laporan MSBD Kelompok 3 - Latihan 1

**Nama Anggota:**
- Tabhita Kristy SIlitonga - 251402023 (PM)
- Jevine Jeje Zakarias Simanjuntak - 251402085
- Fadila Lisma Sari - 251402117
- Qairsya Naurel ein Yaliki - 251402120
- Reynald Alvaro Pasaribu - 251402147

---

### Keluaran `docker --version`
Docker version 29.7.2, build a7dcaa6

---

### Keluaran `docker compose version`
Docker Compose version v5.4.0

---

### Keluaran `docker compose ps`
NAME         IMAGE            COMMAND                  SERVICE    CREATED          STATUS                    PORTS
msbd-mongo   mongo:8          "docker-entrypoint.s…"   mongo      30 seconds ago   Up 28 seconds             0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp
msbd-pg      postgres:17      "docker-entrypoint.s…"   postgres   30 seconds ago   Up 28 seconds (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
msbd-redis   redis:7-alpine   "docker-entrypoint.s…"   redis      30 seconds ago   Up 28 seconds             0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp

---

### Keluaran `SELECT version();`
PostgreSQL 17.11 (Debian 17.11-1.pgdg13+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit

---

### Jawaban pertanyaan pemahaman langkah 1

**Apa yang dimaksud dengan Docker Image?**
> ini adalah template yang read only, nanti isinya adalah semua kebutuhan untuk menjalankan sebuah aplikasi, seperti kode program, library, dan konfigurasi. Image ini digunakan sebagai dasar untuk membuat container

**Apa yang dimaksud dengan Container?**
> container inilah wujud nyata/tempat untuk menjalankan aplikasi dari docker image

**Apa fungsi Volume?**
> volume sendiri adalah media penyimpanan data yang bersifat permanen (persistent storage). nah jadi fungsi volume disini untuk menyimpan data dari container agar data tersebut tetap aman dan tidak hilang ketika container dihentikan atau dihapus

---

### Jawaban pertanyaan pemahaman langkah 2

**Apa yang terjadi jika bagian volumes: pada layanan PostgreSQL dihapus, kemudian container dihentikan menggunakan docker compose down -v ?**
> kalau bagian volumes: dihapus, data PostgreSQL nya hanya disimpan di lapisan internal. lalu ketika docker compose down -v dijalani, container sama volume yang dibuat docker compose dihapus/hilang permanen. jadinya saat environment dijalani kembali, PostgreSQL melakukan inisialisasi ulang pakai konfigurasi yang ada di docker-compose.yml

**Mengapa pemetaan post ditulis "5432:5432" dan bukan cukup satu angka? Apa yang harus diubah apabila apabila komputer Anda sudah memiliki PostgreSQL lain yang menggunakan port 5432?**
> 5432:5432 dipakai untuk menghubungkan port pada komputer dengan port PostgreSQL di dalam container. Angka pertamanya yang menjadi port pada komputer, sedangkan angka kedua jadi port PostgreSQL di dalam container. Jadi kalau port 5432 udah digunakan oleh PostgreSQL lain, port di komputer bisa diganti, misal menjadi "5433:5432". Jadi PostgreSQL di dalam container tetap pakai port 5432 tapi bisa diakses melalui port 5433

**Apa fungsi block healthcheck? Mengapa healthcheck penting ketika terdapat layanan lain yang bergantung pada basis data?**
> healthcheck fungsinya untuk memastikan layanan di dalam container bener bener siap beroprasi atau tidak. Perintahnya ngecek kesiapan PostgreSQL menerima query secara berkala. itu penting untuk layanan lain yang bergantung pada basis data biar layanannya dinyalakan setelah basis data siap, sehingga mencegah terjadinya kegagalan koneksi pas di startup

**Menyimpan password langsung di dalam docker-compose.yml merupakan praktik yang kurang baik. Sebutkan satu cara yang lebih aman dan jelaskan mengapa hal tersebut penting ketika berkas masuk ke repositori Git.**
> cara yang lebih aman dengan memisahkan kredensial ke dalam berkas lingkungan terpisah, baru memasukkan berkas .env ke dalam aturan .gitignore . ini penting untuk mencegah kebocoran data sensitif saat berkas docker-compose.yml dunggah ke repositori Git publik maupun privat

---

### Jawaban pertanyaan pemahaman langkah 3

**1. Satu aktivitas yang menurut Anda lebih cepat dilakukan menggunakan psql.**
> kalau hanya mengecek hal hal kecil dan cepat seperti mengecek versi database atau hal lain yang punya query sedikit, menurut kami psql lebih cepat karena tinggal ketik di terminal, gak perlu buka aplikasi dan tunggu loading.

**2. Satu aktivitas yang menurut Anda lebih cepat dilakukan menggunakan DBeaver.**
> kalau mau lihat struktur tabel atau hubungan antar tabel, Dbeaver menurut kami lebih cepat karena tinggal buka aplikasi lalu bisa dilihat lewat ER diagram, ga perlu ketik ketik query kalo hanya lihat struktur

---

### Jawaban pertanyaan pemahaman langkah 4

**Hasil Query V1**
> Sebelum menjalankan query V1, database Pagila dibuat dengan perintah createdb -U msbd pagila dan di restore menggunakan file `pagila.dump` dengan perintah  pg_restore -U msbd -d pagila --no-owner /dump/pagila.dump. Setelah itu dilakukan pengecekan tabel menggunakan `\dt` dan ditemukan 21 tabel. Bukti : `bukti/langkah4-restore.png`


> SELECT count(*)
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';

>  count 
-------
    21
(1 row)

> Bukti : `bukti/langkah4-V1.png`

**Hasil Query V2**
> SELECT relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS ukuran
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;

>relname      | ukuran  
------------------+---------
 rental           | 2352 kB
 film             | 952 kB
 payment_p2017_04 | 656 kB
 payment_p2017_03 | 568 kB
 film_actor       | 488 kB
 inventory        | 440 kB
 payment_p2017_02 | 296 kB
 payment_p2017_01 | 248 kB
 customer         | 216 kB
 address          | 160 kB
(10 rows)

> Bukti : `bukti/langkah4-V2.png`

**Hasil Query V3**
> SELECT f.title, count(*) AS total_sewa
FROM rental r
JOIN inventory i
  ON i.inventory_id = r.inventory_id
JOIN film f
  ON f.film_id = i.film_id
GROUP BY f.title
ORDER BY total_sewa DESC
LIMIT 5;

> title        | total_sewa 
---------------------+------------
 BUCKET BROTHERHOOD  |         34
 ROCKETEER MOTHER    |         33
 RIDGEMONT SUBMARINE |         32
 SCALAWAG DUCK       |         32
 FORWARD TEMPLE      |         32
(5 rows)

> Bukti : `bukti/langkah4-V3.png`

**Hasil V4 - EXPLAIN ANALYZE**
> QUERY PLAN                                                             
------------------------------------------------------------------------------------------------------------------------------------
 HashAggregate  (cost=713.69..723.69 rows=1000 width=23) (actual time=19.186..19.330 rows=958 loops=1)
   Group Key: f.title
   Batches: 1  Memory Usage: 193kB
   ->  Hash Join  (cost=238.57..633.47 rows=16044 width=15) (actual time=2.446..14.579 rows=16044 loops=1)
         Hash Cond: (i.film_id = f.film_id)
         ->  Hash Join  (cost=128.07..480.67 rows=16044 width=2) (actual time=1.591..9.919 rows=16044 loops=1)
               Hash Cond: (r.inventory_id = i.inventory_id)
               ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=4) (actual time=0.051..2.607 rows=16044 loops=1)
               ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=1.472..1.474 rows=4581 loops=1)
                     Buckets: 8192  Batches: 1  Memory Usage: 234kB
                     ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.007..0.596 rows=4581 loops=1)
         ->  Hash  (cost=98.00..98.00 rows=1000 width=19) (actual time=0.833..0.834 rows=1000 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 60kB
               ->  Seq Scan on film f  (cost=0.00..98.00 rows=1000 width=19) (actual time=0.012..0.547 rows=1000 loops=1)
 Planning Time: 3.331 ms
 Execution Time: 19.576 ms

 > Bukti : `bukti/langkah4-V4.png`

 **Kalimat: "Yang paling membingungkan dari keluaran ini adalah ..."**
 > Yang paling membingungkan dari keluaran ini adalah banyak informasi yang ditampilkan seperti HashAggregate, Hash Join, Seq Scan, dan angka-angka yang ditampilkan, sehingga belum memahami bagaimana PostgreSQL menggunakan informasi tersebut untuk menjalankan query