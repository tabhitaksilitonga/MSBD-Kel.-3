-- ============================================================
-- Q20: BRIN vs B-TREE PADA terjadi_pada
-- Data diisi berurutan waktu, jadi korelasi fisik tinggi (cocok untuk BRIN).
-- Bandingkan plan, waktu, dan ukuran: tanpa index, BRIN, B-tree.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q20_brin_vs_btree.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Korelasi terjadi_pada  2. Plan tiap skenario
-- 3. Execution Time  4. Buffers  5. Fastest dan median  6. Ukuran index
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

\echo --- Q20 korelasi fisik (dekat 1 = cocok untuk BRIN) ---
SELECT attname, correlation
FROM pg_stats
WHERE schemaname = 'lab6' AND tablename = 'event_log'
  AND attname IN ('terjadi_pada', 'customer_id');

\echo --- Q20 baseline | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';

\echo --- Q20 baseline | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';

\echo --- Q20 baseline | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';
CREATE INDEX ev_ts_brin
ON lab6.event_log USING brin (terjadi_pada);
ANALYZE lab6.event_log;

\echo --- Q20 BRIN | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';

\echo --- Q20 BRIN | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';

\echo --- Q20 BRIN | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';
\echo --- Q20 ukuran ev_ts_brin ---
SELECT c.relname AS indeks,
       pg_size_pretty(pg_relation_size(c.oid)) AS ukuran,
       pg_relation_size(c.oid) AS bytes
FROM pg_index i
JOIN pg_class c ON c.oid = i.indexrelid
WHERE i.indrelid = 'lab6.event_log'::regclass
ORDER BY c.relname;
DROP INDEX lab6.ev_ts_brin;

CREATE INDEX ev_ts_btree
ON lab6.event_log (terjadi_pada);
ANALYZE lab6.event_log;

\echo --- Q20 B-tree | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';

\echo --- Q20 B-tree | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';

\echo --- Q20 B-tree | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07'
  AND terjadi_pada <  timestamptz '2024-06-02 00:00+07';
\echo --- Q20 ukuran ev_ts_btree ---
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
