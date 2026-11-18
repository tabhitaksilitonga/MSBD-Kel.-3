-- Diminta: membandingkan waktu hashing bcrypt cost 6, cost 10, dan MD5.
-- Dipilih: EXPLAIN ANALYZE untuk mengukur waktu eksekusi.
-- Alternatif: membandingkan kecepatan berdasarkan perkiraan tidak dipilih karena tidak menghasilkan bukti waktu nyata.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

EXPLAIN ANALYZE
SELECT crypt('password123', gen_salt('bf', 6));

EXPLAIN ANALYZE
SELECT crypt('password123', gen_salt('bf', 10));

EXPLAIN ANALYZE
SELECT md5('password123');
