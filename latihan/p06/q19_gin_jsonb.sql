-- ============================================================
-- Q19: GIN PADA payload JSONB: jsonb_ops vs jsonb_path_ops
-- Query containment yang selektif (sekitar 0,3% baris).
-- Bandingkan ukuran dan waktu dua operator class.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q19_gin_jsonb.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Plan baseline, jsonb_ops, jsonb_path_ops
-- 2. Execution Time  3. Buffers  4. Fastest dan median  5. Ukuran index
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

\echo --- Q19 baseline | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';

\echo --- Q19 baseline | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';

\echo --- Q19 baseline | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';
CREATE INDEX ev_payload_gin
ON lab6.event_log USING gin (payload);
ANALYZE lab6.event_log;

\echo --- Q19 GIN jsonb_ops (default) | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';

\echo --- Q19 GIN jsonb_ops (default) | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';

\echo --- Q19 GIN jsonb_ops (default) | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';
\echo --- Q19 ukuran ev_payload_gin (jsonb_ops) ---
SELECT c.relname AS indeks,
       pg_size_pretty(pg_relation_size(c.oid)) AS ukuran,
       pg_relation_size(c.oid) AS bytes
FROM pg_index i
JOIN pg_class c ON c.oid = i.indexrelid
WHERE i.indrelid = 'lab6.event_log'::regclass
ORDER BY c.relname;
DROP INDEX lab6.ev_payload_gin;

CREATE INDEX ev_payload_gin_path
ON lab6.event_log USING gin (payload jsonb_path_ops);
ANALYZE lab6.event_log;

\echo --- Q19 GIN jsonb_path_ops | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';

\echo --- Q19 GIN jsonb_path_ops | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';

\echo --- Q19 GIN jsonb_path_ops | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE payload @> '{"promo": true, "kanal": 1, "perangkat": 3}';
\echo --- Q19 ukuran ev_payload_gin_path (jsonb_path_ops) ---
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
