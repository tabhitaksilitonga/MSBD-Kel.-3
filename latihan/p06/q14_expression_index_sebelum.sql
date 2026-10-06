-- ============================================================
-- Q14: EXPRESSION INDEX - SEBELUM INDEX EKSPRESI
-- Pencarian email tidak peka huruf besar/kecil memakai lower(email).
-- Index biasa pada email tidak bisa dipakai untuk lower(email).
--
-- Jalankan:
--   docker compose exec -T postgres psql -U msbd -d latihan < latihan/p06/q14_expression_index_sebelum.sql
-- File ini berdiri sendiri: index percobaan dibersihkan dulu (hanya PK
-- yang aktif), dan dibersihkan lagi di akhir.
-- Catat:
-- 1. Plan tanpa index  2. Plan dengan index biasa pada email
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

\echo --- Q14 baseline tanpa index | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';

\echo --- Q14 baseline tanpa index | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';

\echo --- Q14 baseline tanpa index | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';
CREATE INDEX ev_email_idx ON lab6.event_log (email);
ANALYZE lab6.event_log;

\echo --- Q14 index biasa pada email, query lower(email) | RUN 1 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';

\echo --- Q14 index biasa pada email, query lower(email) | RUN 2 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';

\echo --- Q14 index biasa pada email, query lower(email) | RUN 3 ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE lower(email) = 'user1500000@contoh.ac.id';
\echo --- Q14 pembanding: email = ... tanpa lower, cukup 1 run ---
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, customer_id, email
FROM lab6.event_log
WHERE email = 'user1500000@contoh.ac.id';

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
