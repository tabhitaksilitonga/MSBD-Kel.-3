-- ============================================================
-- Q7: BASELINE TANPA INDEX
-- Tujuan:
-- Mengukur performa query sebelum menggunakan index.
-- ============================================================

-- Hapus index yang digunakan pada Q8 dan Q9
DROP INDEX IF EXISTS lab6.ev_salah_idx;
DROP INDEX IF EXISTS lab6.ev_benar_idx;

-- Query baseline
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, jumlah
FROM lab6.event_log
WHERE customer_id = 4211
  AND terjadi_pada >= timestamptz '2024-06-01 00:00+07'
ORDER BY terjadi_pada DESC
LIMIT 20;

-- Jalankan query sebanyak 3 kali.
-- Catat:
-- 1. Execution Time
-- 2. Buffers
-- 3. Node/plan yang digunakan
-- 4. Apakah terdapat Sort
-- 5. Fastest dan median