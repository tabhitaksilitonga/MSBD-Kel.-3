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

## Q1–Q21

### Q1
Dari hasil pengukuran menggunakan fungsi pg_total_relation_size(), tabel lab6.event_log memiliki ukuran penyimpanan sebesar XX MB. Dengan jumlah data 2 juta baris, rata-rata satu tuple butuh ruang sebesar XX byte. ukuran itu tidak hanya berasal dari isi kolom, tapi juga dipengaruhi oleh tuple header PostgreSQL, alignment data, serta metadata penyimpanan internal.

### Q2
PostgreSQL nyimpan data dalam halaman berukuran 8 KB.berdasarkan hasil pengujian, setiap halaman dapat menampung sekitar XX tuple. jumlah tuple per halaman dipengaruhi oleh ukuran setiap baris. makin besar ukuran record, makin sedikit jumlah tuple yang dapat masuk ke satu halaman.

### Q3
Kolom dengan storage x memungkinkan PostgreSQL menggunakan mekanisme TOAST. TOAST digunakan untuk menangani data berukuran besar dengan cara melakukan kompresi atau memindahkan data ke tabel penyimpanan eksternal. pada tabel event_log, kolom seperti payload bertipe JSONB berpotensi menggunakan TOAST karena ukurannya dapat berkembang.

### Q4
Fillfactor menentukan jumlah ruang kosong yang disediakan pada setiap halaman. tabel dengan fillfactor 80 memiliki ruang kosong lebih besar sehingga PostgreSQL memiliki peluang lebih tinggi melakukan HOT Update. sedangkan fillfactor 100 mengisi halaman hampir penuh sehingga ketika terjadi UPDATE, PostgreSQL lebih sering membuat tuple baru pada lokasi berbeda.

### Q5

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
