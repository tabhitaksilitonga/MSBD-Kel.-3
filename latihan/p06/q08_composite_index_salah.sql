-- ============================================================
-- Q8: INDEX DENGAN URUTAN KOLOM (terjadi_pada, customer_id)
-- Tujuan:
-- Melihat pengaruh urutan kolom pada B-tree index.
-- ============================================================

-- Pastikan index Q9 tidak digunakan
DROP INDEX IF EXISTS lab6.ev_benar_idx;

-- Buat index dengan urutan kolom:
-- (terjadi_pada, customer_id)
CREATE INDEX ev_salah_idx
ON lab6.event_log (terjadi_pada, customer_id);

-- Jalankan query sebanyak 3 kali
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, jumlah
FROM lab6.event_log
WHERE customer_id = 4211
  AND terjadi_pada >= timestamptz '2024-06-01 00:00+07'
ORDER BY terjadi_pada DESC
LIMIT 20;

-- Perhatikan:
-- 1. Apakah index digunakan?
-- 2. Apakah terdapat Sort?
-- 3. Execution Time
-- 4. Buffers
-- 5. Plan yang digunakan
-- 6. Fastest dan median