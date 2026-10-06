-- ============================================================
-- Q16: COVERING INDEX - COMPOSITE BIASA
-- Index (customer_id, terjadi_pada DESC) tanpa INCLUDE.
-- Kolom jumlah tidak ada di index, jadi harus diambil dari heap.
-- event_id sengaja tidak dipilih agar Q17 bisa Index Only Scan.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q16_covering_index_biasa.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Plan yang digunakan  2. Execution Time  3. Buffers
-- 4. Fastest dan median  5. Ukuran index
-- ============================================================

\timing on
SET max_parallel_workers_per_gather = 0;

DROP INDEX IF EXISTS lab6.ev_salah_idx,
  lab6.ev_benar_idx,
  lab6.ev_gagal_part_idx,
  lab6.ev_status_full_idx,
  lab6.ev_email_idx,
  lab6.ev_email_lower_idx,
  lab6.ev_cover_plain_idx,
  lab6.ev_cover_idx,
  lab6.ev_tags_gin,
  lab6.ev_payload_gin,
  lab6.ev_payload_gin_path,
  lab6.ev_ts_brin,
  lab6.ev_ts_btree;
ANALYZE lab6.event_log;

CREATE INDEX ev_cover_plain_idx
ON lab6.event_log (customer_id, terjadi_pada DESC);
ANALYZE lab6.event_log;

\echo --- Q16 composite biasa | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE customer_id BETWEEN 4200 AND 4300
ORDER BY customer_id, terjadi_pada DESC;

\echo --- Q16 composite biasa | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE customer_id BETWEEN 4200 AND 4300
ORDER BY customer_id, terjadi_pada DESC;

\echo --- Q16 composite biasa | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE customer_id BETWEEN 4200 AND 4300
ORDER BY customer_id, terjadi_pada DESC;
\echo --- Q16 ukuran ev_cover_plain_idx ---
SELECT c.relname AS indeks,
       pg_size_pretty(pg_relation_size(c.oid)) AS ukuran,
       pg_relation_size(c.oid) AS bytes
FROM pg_index i
JOIN pg_class c ON c.oid = i.indexrelid
WHERE i.indrelid = 'lab6.event_log'::regclass
ORDER BY c.relname;

-- Bersihkan index percobaan agar tabel kembali hanya berisi PK
DROP INDEX IF EXISTS lab6.ev_salah_idx,
  lab6.ev_benar_idx,
  lab6.ev_gagal_part_idx,
  lab6.ev_status_full_idx,
  lab6.ev_email_idx,
  lab6.ev_email_lower_idx,
  lab6.ev_cover_plain_idx,
  lab6.ev_cover_idx,
  lab6.ev_tags_gin,
  lab6.ev_payload_gin,
  lab6.ev_payload_gin_path,
  lab6.ev_ts_brin,
  lab6.ev_ts_btree;
