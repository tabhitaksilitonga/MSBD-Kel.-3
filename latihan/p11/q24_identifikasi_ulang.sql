-- Diminta: menghitung kombinasi unik kota dan tanggal lahir,
--          lalu membandingkannya setelah tanggal lahir digeneralisasi menjadi tahun.
-- Dipilih: menggunakan COUNT DISTINCT melalui subquery agar jumlah kombinasi dapat dibandingkan.
-- Alternatif: menghapus tanggal lahir sepenuhnya tidak dipilih karena latihan meminta generalisasi.

-- Menghitung kombinasi sebelum dan sesudah generalisasi
WITH data_asli AS (
    SELECT COUNT(*) AS jumlah
    FROM (
        SELECT DISTINCT kota, lahir
        FROM lab11.pelanggan
    ) AS d
),
data_generalisasi AS (
    SELECT COUNT(*) AS jumlah
    FROM (
        SELECT DISTINCT
            kota,
            date_trunc('year', lahir)::date AS lahir_tahun
        FROM lab11.pelanggan
    ) AS d
)
SELECT
    data_asli.jumlah AS kombinasi_asli,
    data_generalisasi.jumlah AS kombinasi_generalisasi,
    ROUND(
        (
            (data_asli.jumlah - data_generalisasi.jumlah)::numeric
            / NULLIF(data_asli.jumlah, 0)
        ) * 100,
        2
    ) AS penurunan_persen
FROM data_asli, data_generalisasi;


-- Contoh agregasi yang berpotensi mengungkap identitas seseorang
SELECT
    kota,
    COUNT(*) AS jumlah_pelanggan
FROM lab11.pelanggan
GROUP BY kota
HAVING COUNT(*) = 1;


-- Contoh kombinasi agregasi kota dan tanggal lahir
SELECT
    kota,
    lahir,
    COUNT(*) AS jumlah
FROM lab11.pelanggan
GROUP BY kota, lahir
HAVING COUNT(*) = 1;
