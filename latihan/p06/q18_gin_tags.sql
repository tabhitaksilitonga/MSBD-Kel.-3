-- ============================================================
-- Q18: GIN PADA KOLOM ARRAY tags
-- Operator containment @> pada text[]. Selektivitas rendah
-- (sekitar 8% baris), jadi planner bisa tetap memilih Seq Scan.
-- Catat apa adanya.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q18_gin_tags.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Plan baseline vs GIN  2. Execution Time  3. Buffers
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

\echo --- Q18 baseline | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE tags @> ARRAY['kanal:2','sumber:1'];

\echo --- Q18 baseline | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE tags @> ARRAY['kanal:2','sumber:1'];

\echo --- Q18 baseline | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE tags @> ARRAY['kanal:2','sumber:1'];
CREATE INDEX ev_tags_gin
ON lab6.event_log USING gin (tags);
ANALYZE lab6.event_log;

\echo --- Q18 GIN tags | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE tags @> ARRAY['kanal:2','sumber:1'];

\echo --- Q18 GIN tags | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE tags @> ARRAY['kanal:2','sumber:1'];

\echo --- Q18 GIN tags | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE tags @> ARRAY['kanal:2','sumber:1'];
-- Opsional: paksa planner memakai index untuk melihat biayanya
SET enable_seqscan = off;
\echo --- Q18 GIN tags (enable_seqscan off) | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM lab6.event_log
WHERE tags @> ARRAY['kanal:2','sumber:1'];
RESET enable_seqscan;

\echo --- Q18 ukuran ev_tags_gin ---
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
