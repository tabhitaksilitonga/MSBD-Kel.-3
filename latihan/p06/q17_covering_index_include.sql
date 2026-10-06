-- ============================================================
-- Q17: COVERING INDEX DENGAN INCLUDE (jumlah)
-- Index Only Scan butuh visibility map: ukur sekali sebelum VACUUM
-- (lihat Heap Fetches), lalu VACUUM dan ukur 3 kali.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q17_covering_index_include.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Apakah Index Only Scan muncul?  2. Heap Fetches sebelum/sesudah VACUUM
-- 3. Execution Time  4. Buffers  5. Fastest dan median
-- 6. Ukuran dibanding index biasa (Q16)
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

CREATE INDEX ev_cover_plain_idx  -- hanya untuk pembanding ukuran
ON lab6.event_log (customer_id, terjadi_pada DESC);

CREATE INDEX ev_cover_idx
ON lab6.event_log (customer_id, terjadi_pada DESC)
INCLUDE (jumlah);

\echo --- Q17 ukuran ev_cover_plain_idx vs ev_cover_idx ---
SELECT c.relname AS indeks,
       pg_size_pretty(pg_relation_size(c.oid)) AS ukuran,
       pg_relation_size(c.oid) AS bytes
FROM pg_index i
JOIN pg_class c ON c.oid = i.indexrelid
WHERE i.indrelid = 'lab6.event_log'::regclass
ORDER BY c.relname;
DROP INDEX lab6.ev_cover_plain_idx;  -- supaya planner hanya melihat index INCLUDE

\echo --- Q17 INCLUDE sebelum VACUUM (lihat Heap Fetches) | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE customer_id BETWEEN 4200 AND 4300
ORDER BY customer_id, terjadi_pada DESC;
VACUUM (ANALYZE) lab6.event_log;

\echo --- Q17 INCLUDE setelah VACUUM | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE customer_id BETWEEN 4200 AND 4300
ORDER BY customer_id, terjadi_pada DESC;

\echo --- Q17 INCLUDE setelah VACUUM | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE customer_id BETWEEN 4200 AND 4300
ORDER BY customer_id, terjadi_pada DESC;

\echo --- Q17 INCLUDE setelah VACUUM | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah
FROM lab6.event_log
WHERE customer_id BETWEEN 4200 AND 4300
ORDER BY customer_id, terjadi_pada DESC;

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
