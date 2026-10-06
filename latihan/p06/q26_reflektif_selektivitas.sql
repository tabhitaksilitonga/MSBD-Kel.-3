-- Q26
-- Status GAGAL dipilih untuk index karena hanya memiliki fraksi 2%.
-- Jumlah baris yang harus dicari sedikit dibandingkan keseluruhan tabel.

-- Status SUKSES lebih cocok menggunakan Seq Scan karena memiliki fraksi 84%.
-- Sebagian besar tabel harus dibaca sehingga penggunaan index menjadi kurang efisien.

-- Titik peralihan antara Index Scan dan Seq Scan bukan angka tetap.
-- Hal ini dipengaruhi oleh random_page_cost, ukuran tabel, distribusi data,
-- jumlah halaman yang harus dibaca, correlation, dan kondisi cache.