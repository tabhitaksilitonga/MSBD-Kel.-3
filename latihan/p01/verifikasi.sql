-- verifikasi.sql: query read-only untuk verifikasi koneksi dan schema

-- Versi PostgreSQL
SELECT version();

-- Database aktif dan user
SELECT current_database() AS database_name;
SELECT session_user AS connecting_user;
SELECT now() AS server_time;

-- Hitung tabel public
SELECT COUNT(*) AS public_table_count
FROM information_schema.tables
WHERE table_schema = 'public';

-- Daftar tabel (limit 50)
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name
LIMIT 50;

-- Selesai

