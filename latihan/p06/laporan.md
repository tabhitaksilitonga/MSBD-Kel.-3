# Laporan Latihan Kelompok Pertemuan 6

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |
| :--- | :--- | :--- | :--- |
| Tabhita Kristy SIlitonga | 251402023 | Project Manager, Langkah 1 (Q00) Setup 2 Juta Baris, Struktur Repo, Finalisasi laporan | 55aa8fc |
| Jevine Jeje Zakarias Simanjuntak | 251402085 | Langkah 2 (Q01–Q06) Anatomi Penyimpanan (Halaman, TOAST, dan HOT Update), Reflektif Q1 & Q6 | 1252149 |
| Fadila Lisma Sari | 251402117 | Langkah 3 (Q07–Q11) Baseline, B-Tree, dan Urutan Kolom Composite Index, Reflektif Q11 | a55bf35 |
| Qairsya Naurel ein Yaliki | 251402120 | Langkah 4 & 5 (Q12–Q21) Partial, Expression, Covering Index, GIN & BRIN, Reflektif Q16 & Q21 | bae3982 |
| Reynald Alvaro Pasaribu | 251402147 | Langkah 6 & 7 (Q22–Q31) Statistik, Selektivitas, Seq Scan, Harga Tulis, dan Rekomendasi Index, Reflektif Q26 & Q31 | a5b21f2 |

---

## Q1–Q31

### Q1
Dari hasil pengukuran menggunakan pg_total_relation_size(), tabel lab6.event_log memiliki ukuran penyimpanan sebesar 501 MB atau 524.902.400 byte. Dengan jumlah data sebanyak 2.000.000 baris, rata-rata ruang penyimpanan yang dibutuhkan adalah sekitar 262,45 byte per baris. Ukuran tersebut tidak hanya berasal dari isi setiap kolom, tetapi juga dipengaruhi oleh tuple header PostgreSQL, alignment data, index, serta struktur penyimpanan internal lainnya.

### Q2
Pengukuran jumlah tuple per halaman dilakukan menggunakan ctid untuk mengelompokkan tuple berdasarkan page tempat data disimpan. Hasil pengujian menunjukkan jumlah minimum sebesar 15 tuple per halaman, maksimum 35 tuple per halaman, dan rata-rata sebesar 34,15 tuple per halaman, dengan total 58.569 halaman terpakai.
Sebagai pembanding, statistik pada pg_class menunjukkan jumlah halaman sebanyak 58.569 halaman dan estimasi jumlah tuple sebesar 2.000.000 tuple, sehingga diperoleh rata-rata katalog sebesar 34,15 tuple per halaman. Hasil perhitungan berdasarkan ctid dan statistik katalog menunjukkan nilai rata-rata yang sama.

### Q3
Hasil pemeriksaan pg_attribute menunjukkan bahwa kolom status, wilayah, kota, email, tags, dan payload memiliki nilai attstorage = 'x' atau extended. Storage jenis ini memungkinkan PostgreSQL menggunakan mekanisme TOAST apabila ukuran data cukup besar.sementara itu, kolom event_id, customer_id, terjadi_pada, dan idempotency_key memiliki nilai attstorage = 'p' atau plain, sedangkan kolom jumlah memiliki nilai attstorage = 'm' atau main.
Mekanisme TOAST membantu PostgreSQL menangani data berukuran besar melalui kompresi atau penyimpanan data di luar heap utama. Oleh karena itu, penggunaan SELECT * dapat menambah biaya pembacaan apabila query ikut mengambil kolom berukuran besar seperti payload, tags, atau kolom bertipe teks yang sebenarnya tidak diperlukan.

### Q4
Pengujian Q4 direncanakan dengan membuat dua tabel, yaitu hot_penuh dengan fillfactor = 100 dan hot_longgar dengan fillfactor = 80. Namun, pada proses pengisian data terjadi error:
cannot insert a non-DEFAULT value into column "event_id"

Hal ini terjadi karena kolom event_id pada tabel hasil LIKE ... INCLUDING ALL tetap menggunakan properti GENERATED ALWAYS AS IDENTITY. Akibatnya, perintah INSERT ... SELECT * tidak dapat memasukkan nilai event_id secara langsung, karena proses insert gagal, kedua tabel tidak memiliki data sehingga perintah UPDATE menghasilkan UPDATE 0 dan nilai n_tup_upd maupun n_tup_hot_upd masih bernilai 0. Oleh karena itu, hasil Q4 ini belum dapat digunakan untuk membandingkan pengaruh fillfactor terhadap HOT Update.

### Q5
Hasil pengukuran pg_relation_size() menunjukkan tabel hot_penuh dan hot_longgar masing-masing memiliki ukuran 0 bytes. hasil tersebut bukan menunjukkan bahwa fillfactor 80 dan fillfactor 100 menggunakan ruang penyimpanan yang sama, tetapi terjadi karena proses pengisian data pada Q4 gagal. Kedua tabel masih kosong akibat error pada kolom identity event_id. jadinya, pengukuran Q5 perlu dilakukan kembali setelah proses insert Q4 berhasil agar ukuran kedua tabel dapat dibandingkan secara valid.

### Q6
Pada Q6 dibuat tabel hot_test untuk menguji hubungan antara HOT Update dan keberadaan index. Namun, proses pengisian data kembali mengalami error pada kolom event_id karena kolom tersebut didefinisikan sebagai GENERATED ALWAYS AS IDENTITY.
Akibat kegagalan insert, tabel hot_test tidak berisi data. Update pada kolom payload menghasilkan UPDATE 0, dengan n_tup_upd = 0 dan n_tup_hot_upd = 0. setelah dibuat index idx_hot_status pada kolom status, update terhadap kolom status juga menghasilkan UPDATE 0, dengan n_tup_upd = 0 dan n_tup_hot_upd = 0. jadinya, hasil Q6 saat ini belum dapat digunakan untuk menarik kesimpulan mengenai HOT Update karena tabel pengujian masih kosong. Pengujian perlu diulang setelah proses insert diperbaiki.

### Q7
Pada kondisi baseline tanpa index, PostgreSQL menggunakan Sequential Scan pada tabel lab6.event_log, kemudian melakukan Sort berdasarkan terjadi_pada DESC, lalu mengambil 20 baris menggunakan Limit. Hasil estimasi menunjukkan 17 baris, sedangkan jumlah aktual yang ditemukan adalah 21 baris sebelum proses Sort dan 20 baris setelah Limit. Sebanyak 1.999.979 baris harus dilewati karena tidak memenuhi kondisi filter. Dari tiga kali pengujian, waktu tercepat adalah 308.006 ms, sedangkan median adalah 1730.742 ms.

### Q8
Pada Q8 dibuat index ev_salah_idx dengan urutan (terjadi_pada, customer_id). Berdasarkan hasil EXPLAIN ANALYZE, PostgreSQL menggunakan Index Scan Backward using ev_salah_idx. Tidak terdapat node Sort karena index dapat menyediakan data dalam urutan terjadi_pada DESC yang dibutuhkan oleh query. Dari tiga kali pengujian, waktu tercepat adalah 30.623 ms dan median 80.723 ms. Buffers pada pengujian kedua dan ketiga adalah shared hit=3175.

### Q9
Pada Q9 digunakan index ev_benar_idx (customer_id, terjadi_pada DESC). Hasil EXPLAIN ANALYZE menunjukkan bahwa PostgreSQL menggunakan Index Scan dengan index tersebut dan tidak membutuhkan operasi Sort. Dari tiga kali pengujian, waktu tercepat adalah 0.270 ms, sedangkan waktu median adalah 0.405 ms. Index dapat langsung digunakan untuk mencari customer_id = 4211 sekaligus membaca data berdasarkan terjadi_pada secara descending.

### Q10
Berdasarkan hasil pengukuran, ev_salah_idx dan ev_benar_idx memiliki ukuran yang sama, yaitu 60 MB. Walaupun urutan kolom pada kedua index berbeda, perubahan urutan tersebut tidak selalu menyebabkan perbedaan ukuran index. Pada data dan kondisi pengujian ini, ukuran keduanya tetap sama. Perbedaan utama kedua index lebih terlihat pada cara index tersebut digunakan oleh PostgreSQL untuk memenuhi kondisi pencarian dan pengurutan.

### Q11
B-tree menyimpan data secara terurut pada bagian leaf. Pada ev_benar_idx (customer_id, terjadi_pada DESC), data dengan customer yang sama sudah dikelompokkan dan diurutkan berdasarkan waktu terbaru. Jadi, PostgreSQL bisa langsung mengambil data sesuai WHERE dan ORDER BY tanpa perlu melakukan Sort lagi. Karena query hanya membutuhkan 20 data, PostgreSQL juga bisa berhenti setelah menemukan 20 data yang sesuai.

### Q22
Berdasarkan hasil pengujian, index `ev_status_idx` efektif untuk status dengan selektivitas rendah seperti `GAGAL` yang hanya berjumlah 2% dari seluruh data. PostgreSQL menggunakan `Bitmap Heap Scan` dan `Bitmap Index Scan` sehingga pencarian dapat dilakukan tanpa membaca seluruh tabel. Sebaliknya, untuk `SUKSES` yang berjumlah 84%, PostgreSQL memilih `Seq Scan` karena sebagian besar baris memenuhi kondisi sehingga membaca tabel secara langsung lebih efisien.

### Q23
Distribusi data menunjukkan bahwa `GAGAL` memiliki 40.000 baris (2%), `SUKSES` 1.680.000 baris (84%), dan `TERTUNDA` 280.000 baris (14%). Pada pengujian `TERTUNDA`, PostgreSQL masih menggunakan `ev_status_idx` dengan `Bitmap Heap Scan` dan `Bitmap Index Scan`. Hal ini menunjukkan bahwa pada data sebesar 14%, index masih dapat memberikan manfaat dalam pencarian.

### Q24
Pengujian dengan `random_page_cost = 1.1` digunakan untuk melihat pengaruh biaya akses halaman secara acak terhadap pemilihan execution plan. Nilai `random_page_cost` yang lebih rendah membuat akses menggunakan index menjadi lebih menarik bagi PostgreSQL. Hasil pengujian ini digunakan untuk melihat apakah perubahan biaya tersebut dapat memengaruhi pilihan antara penggunaan index dan `Seq Scan`.

### Q25
Extended statistics dibuat pada kolom `wilayah` dan `kota` menggunakan `dependencies` dan `ndistinct`. Sebelum `ANALYZE`, PostgreSQL memperkirakan hanya 8.387 baris, sedangkan jumlah actual mencapai 44.444 baris. Setelah `ANALYZE`, estimasi meningkat menjadi 43.868 baris dan jauh lebih mendekati jumlah actual. Hal ini menunjukkan bahwa extended statistics membantu PostgreSQL menghasilkan estimasi jumlah baris yang lebih akurat ketika beberapa kolom memiliki hubungan.

### Q26
Hasil pengujian menunjukkan bahwa tidak ada batas selektivitas yang selalu menentukan kapan index atau `Seq Scan` harus digunakan. Pemilihan execution plan dipengaruhi oleh beberapa faktor seperti `random_page_cost`, ukuran tabel, distribusi data, jumlah halaman yang harus dibaca, correlation, dan kondisi cache. Oleh karena itu, penggunaan index perlu ditentukan berdasarkan kondisi dan pola query yang sebenarnya.

### Q27
Berdasarkan pengujian INSERT sebanyak 200.000 baris, tabel tanpa index memiliki median waktu 1059.442 ms, sedangkan tabel dengan lima index membutuhkan 2720.725 ms. Waktu INSERT meningkat sebesar 156.79% ketika lima index digunakan. Hal ini terjadi karena setiap baris baru tidak hanya dimasukkan ke tabel, tetapi juga harus memperbarui seluruh index yang terkait sehingga index memberikan tambahan biaya pada operasi tulis.

### Q28
Perbandingan ukuran tabel menunjukkan bahwa penggunaan index membutuhkan storage tambahan. Tabel dengan lima index memiliki ukuran total yang lebih besar dibandingkan tabel tanpa index karena setiap index menyimpan struktur tersendiri untuk mempercepat pencarian data. Dengan demikian, penggunaan index tidak hanya memberikan manfaat pada operasi baca, tetapi juga menambah kebutuhan penyimpanan.

### Q29
`idx_scan` digunakan untuk melihat seberapa sering sebuah index digunakan oleh PostgreSQL, sedangkan ukuran index menunjukkan storage yang digunakan oleh masing-masing index. Nilai `idx_scan` dapat digunakan untuk menilai apakah suatu index benar-benar dimanfaatkan oleh query. Index yang jarang digunakan tetapi tetap membutuhkan storage dan biaya pemeliharaan perlu dipertimbangkan kembali penggunaannya.

### Q30
Berdasarkan hasil pengujian, index direkomendasikan untuk kondisi dengan selektivitas tinggi seperti `GAGAL` sebesar 2%. Untuk `TERTUNDA` sebesar 14%, penggunaan index masih dapat dipertimbangkan karena PostgreSQL masih menggunakan Bitmap Index Scan. Sementara itu, `SUKSES` sebesar 84% lebih cocok menggunakan `Seq Scan`. Pada kombinasi `wilayah` dan `kota`, extended statistics dapat digunakan untuk membantu meningkatkan akurasi estimasi PostgreSQL.

### Q31
Dasar numerik menunjukkan bahwa manfaat index harus dibandingkan dengan biaya yang ditimbulkannya. Status `GAGAL` dengan selektivitas 2% dapat memanfaatkan index, sedangkan `SUKSES` dengan 84% lebih sesuai menggunakan `Seq Scan`. Extended statistics juga meningkatkan estimasi dari 8.387 menjadi 43.868 baris, mendekati actual 44.444 baris. Dari sisi operasi tulis, penggunaan lima index meningkatkan median waktu INSERT dari 1059.442 ms menjadi 2720.725 ms atau 156.79% lebih lambat. Hasil ini menunjukkan bahwa index sebaiknya dibuat berdasarkan kebutuhan query dan selektivitas data, bukan sebanyak mungkin.

#### Kondisi Uji
- **Tabel:** `lab6.event_log` (~2.000.000 baris)
- **Query:** Mencari `event_id, jumlah` dengan filter `customer_id = 4211` dan `terjadi_pada >= '2024-06-01'`, diurutkan `terjadi_pada DESC`, dibatasi `LIMIT 20`.
- **Metode:** Setiap skenario dijalankan 3 kali menggunakan `EXPLAIN (ANALYZE, BUFFERS)`. Hasil run ke-1 diabaikan untuk menghindari bias cache.

---

#### Q7: Baseline Tanpa Index
- **Plan:** `Seq Scan` → `Sort` (quicksort) → `Limit`
- **Analisis:** Tanpa index, PostgreSQL memindai seluruh ~2 juta baris (Seq Scan) dan membuang 1.999.979 baris yang tidak cocok. Node `Sort` wajib muncul karena data tidak terurut, memakan waktu dan memori.

#### Q8: Index Urutan Kurang Tepat `(terjadi_pada, customer_id)`
- **Index:** `ev_salah_idx`
- **Plan:** `Index Scan Backward` → `Limit`
- **Analisis:** Index digunakan dan node `Sort` hilang karena data sudah terurut berdasarkan `terjadi_pada`. Namun, karena kolom equality (`customer_id`) ada di posisi kedua, PostgreSQL tetap harus men-scan banyak entry index dari berbagai customer sebelum menemukan 20 baris yang cocok.

#### Q9: Index Urutan Tepat `(customer_id, terjadi_pada DESC)`
- **Index:** `ev_benar_idx`
- **Plan:** `Index Scan` → `Limit`
- **Analisis:** Kolom equality (`customer_id`) di posisi pertama memungkinkan PostgreSQL langsung melompat ke data customer yang dicari. Karena `terjadi_pada DESC` sudah terurut di dalam index, node `Sort` tidak diperlukan. Ditambah `LIMIT 20`, proses berhenti sangat cepat (early termination).

#### Q10: Perbandingan Ukuran Index
- `ev_salah_idx` (terjadi_pada, customer_id) = **60 MB**
- `ev_benar_idx` (customer_id, terjadi_pada DESC) = **60 MB**
- **Analisis:** Ukuran kedua index sama persis. B-Tree menyimpan semua entry dari kolom yang di-index; urutan kolom hanya mempengaruhi struktur leaf page, bukan ukuran total file index.

#### Q11: Refleksi B-Tree dan Pengurutan (Sort)
Index `ev_benar_idx` secara fisik menyimpan data terurut berdasarkan `customer_id`, lalu di dalam customer yang sama terurut berdasarkan `terjadi_pada DESC`. Karena pola query melakukan filter equality pada kolom pertama index dan ORDER BY pada kolom kedua index (yang sudah didefinisikan DESC), leaf B-Tree sudah menghasilkan data dalam urutan yang diminta. Akibatnya, optimizer PostgreSQL sepenuhnya menghilangkan node `Sort` dan memanfaatkan `LIMIT` untuk berhenti membaca index begitu 20 baris terkumpul.

---

#### Tabel Perbandingan

| Query / Index | Tercepat | Median | Buffers (Hit) | Ukuran | Keputusan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Q7** - Tanpa Index | 308.006 ms | 1.730.742 ms | ~14.951 | - | Terlalu lambat (Full Seq Scan) |
| **Q8** - `ev_salah_idx` `(terjadi_pada, customer_id)` | 30.623 ms | 80.723 ms | 3.175 | 60 MB |  Cukup cepat, tapi kurang optimal |
| **Q9** - `ev_benar_idx` `(customer_id, terjadi_pada DESC)` | 0.270 ms | 0.405 ms | 23 | 60 MB | Terpilih(Paling efisien) |

---

#### Rekomendasi Akhir
1. **Urutan kolom pada Composite Index sangat kritis.** Selalu letakkan kolom dengan operasi equality (`=`) di posisi paling depan, diikuti oleh kolom range atau `ORDER BY`.
2. **Manfaatkan B-Tree untuk menghindari Sort.** Jika kolom `ORDER BY` merupakan bagian dari index dan urutannya sesuai (ASC/DESC), PostgreSQL dapat menghilangkan operasi Sort yang mahal.
3. **Index yang tepat mengoptimalkan LIMIT.** Dengan index yang terurut sesuai `ORDER BY`, database dapat melakukan *early termination* (berhenti membaca data) begitu batas `LIMIT` terpenuhi.
4. **Ukuran index tidak bergantung pada urutan kolom.** Pertimbangan urutan kolom harus didasarkan pada pola query (read), bukan kekhawatiran akan perbedaan ukuran penyimpanan.

#### Penggunaan AI dan Verifikasi
- **Bantuan AI:** AI (Qwen) digunakan untuk membantu memformat output mentah `EXPLAIN ANALYZE` menjadi tabel perbandingan yang rapi, serta membantu merumuskan kalimat analisis dan rekomendasi akhir agar lebih terstruktur.
- **Verifikasi:** Seluruh data kuantitatif (Execution Time, Buffers, Ukuran Index) di atas adalah **hasil asli** yang dieksekusi dan dicatat langsung oleh anggota kelompok (Fadila) pada database PostgreSQL lokal. AI tidak mengarang atau mengubah angka hasil pengukuran.
