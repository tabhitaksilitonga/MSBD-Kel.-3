-- 1. Pembuatan Indeks GIN
CREATE INDEX idx_notifikasi_data_gin ON notifikasi USING GIN (data);

-- 2. Menunjukkan definisi (jalankan perintah ini di konsol psql)
-- \d notifikasi

-- 3. Kueri utama
SELECT 
    data ->> 'nomor_transaksi' AS nomor_transaksi,
    data -> 'pelanggan' ->> 'kota' AS kota_pelanggan,
    (data ->> 'jumlah')::NUMERIC AS jumlah
FROM notifikasi
WHERE data @> '{"status": "lunas"}';
