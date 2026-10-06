-- ============================================================
-- Q12: PARTIAL INDEX - BASELINE TANPA INDEX
-- Query event GAGAL terbaru (sekitar 2% baris). Hanya PK yang ada.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q12_partial_index_baseline.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Plan/node yang digunakan  2. Ada Sort atau tidak
-- 3. Execution Time  4. Buffers  5. Fastest dan median
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

\echo --- Q12 baseline | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE status = 'GAGAL'
ORDER BY terjadi_pada DESC
LIMIT 20;

\echo --- Q12 baseline | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE status = 'GAGAL'
ORDER BY terjadi_pada DESC
LIMIT 20;

\echo --- Q12 baseline | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE status = 'GAGAL'
ORDER BY terjadi_pada DESC
LIMIT 20;

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
