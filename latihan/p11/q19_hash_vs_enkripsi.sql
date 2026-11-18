-- Diminta: melakukan hashing kata sandi akun dan membuktikan hasil hash berbeda.
-- Dipilih: crypt() dengan gen_salt('bf', 8) karena menggunakan bcrypt dan salt acak.
-- Alternatif: MD5 tidak dipilih karena terlalu cepat dan kurang aman untuk hashing kata sandi.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Membuat dua hash dari kata sandi yang sama
SELECT
    crypt('password123', gen_salt('bf', 8)) AS hash_1,
    crypt('password123', gen_salt('bf', 8)) AS hash_2;

-- Membuktikan kedua hash berbeda
SELECT
    crypt('password123', gen_salt('bf', 8)) =
    crypt('password123', gen_salt('bf', 8)) AS hasil_sama;
