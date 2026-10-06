-- ============================================================
-- Q10: PERBANDINGAN UKURAN INDEX
-- Tujuan:
-- Membandingkan ukuran ev_salah_idx dan ev_benar_idx.
-- ============================================================

-- Pastikan index benar tersedia
DROP INDEX IF EXISTS lab6.ev_benar_idx;

CREATE INDEX ev_benar_idx
ON lab6.event_log (customer_id, terjadi_pada DESC);

-- Ukuran ev_benar_idx
SELECT
    'ev_benar_idx' AS index_name,
    pg_size_pretty(
        pg_relation_size('lab6.ev_benar_idx')
    ) AS ukuran;


-- Buat kembali index dengan urutan kolom berbeda
CREATE INDEX ev_salah_idx
ON lab6.event_log (terjadi_pada, customer_id);

-- Ukuran ev_salah_idx
SELECT
    'ev_salah_idx' AS index_name,
    pg_size_pretty(
        pg_relation_size('lab6.ev_salah_idx')
    ) AS ukuran;


-- Hasil pengukuran:
-- ev_benar_idx = 60 MB
-- ev_salah_idx = 60 MB
--
-- Pada dataset ini, kedua index memiliki ukuran yang sama
-- walaupun urutan kolomnya berbeda.