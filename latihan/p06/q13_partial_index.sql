-- ============================================================
-- Q13: PARTIAL INDEX WHERE status = 'GAGAL'
-- Bandingkan dengan Q12, uji predikat yang tidak cocok,
-- lalu bandingkan ukuran partial index dengan index penuh.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q13_partial_index.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Apakah partial index dipakai?  2. Apakah Sort masih ada?
-- 3. Execution Time  4. Buffers  5. Fastest dan median
-- 6. Ukuran partial vs index penuh
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

CREATE INDEX ev_gagal_part_idx
ON lab6.event_log (terjadi_pada DESC)
WHERE status = 'GAGAL';
ANALYZE lab6.event_log;

\echo --- Q13 partial index | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE status = 'GAGAL'
ORDER BY terjadi_pada DESC
LIMIT 20;

\echo --- Q13 partial index | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE status = 'GAGAL'
ORDER BY terjadi_pada DESC
LIMIT 20;

\echo --- Q13 partial index | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE status = 'GAGAL'
ORDER BY terjadi_pada DESC
LIMIT 20;
\echo --- Q13 predikat tidak cocok (status TERTUNDA), cukup 1 run ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE status = 'TERTUNDA'
ORDER BY terjadi_pada DESC
LIMIT 20;

-- Index penuh sebagai pembanding ukuran
CREATE INDEX ev_status_full_idx
ON lab6.event_log (status, terjadi_pada DESC);

\echo --- Q13 ukuran ev_gagal_part_idx vs ev_status_full_idx ---
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
