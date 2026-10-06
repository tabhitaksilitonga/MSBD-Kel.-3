-- ============================================================
-- Q9: INDEX DENGAN URUTAN KOLOM YANG SESUAI
-- Tujuan:
-- Membandingkan index yang sesuai dengan pola query.
-- ============================================================

-- Hapus index Q8
DROP INDEX IF EXISTS lab6.ev_salah_idx;

-- Buat index:
-- customer_id sebagai kolom pertama
-- terjadi_pada diurutkan DESC
CREATE INDEX ev_benar_idx
ON lab6.event_log (customer_id, terjadi_pada DESC);

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
-- 2. Apakah Sort masih diperlukan?
-- 3. Execution Time
-- 4. Buffers
-- 5. Plan yang digunakan
-- 6. Fastest dan median