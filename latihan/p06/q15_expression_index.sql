-- ============================================================
-- Q15: EXPRESSION INDEX PADA lower(email)
-- Buat index ekspresi, ulangi query Q14, bandingkan ukuran
-- dengan index biasa pada email.
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q15_expression_index.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Apakah index ekspresi dipakai?  2. Execution Time
-- 3. Buffers  4. Fastest dan median  5. Ukuran kedua index
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

CREATE INDEX ev_email_idx ON lab6.event_log (email);  -- hanya untuk pembanding ukuran

CREATE INDEX ev_email_lower_idx
ON lab6.event_log (lower(email));
ANALYZE lab6.event_log;

\echo --- Q15 expression index | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';

\echo --- Q15 expression index | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';

\echo --- Q15 expression index | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';
\echo --- Q15 ukuran ev_email_idx vs ev_email_lower_idx ---
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
