
-- Q9: FORCE RLS dan BYPASSRLS
-- Permintaan: Menguji perilaku pemilik tabel dan role BYPASSRLS.
-- Keputusan: Membandingkan akses sebelum dan sesudah FORCE RLS.
-- Alternatif ditolak: Menganggap semua role otomatis tunduk pada RLS.

-- A. Pemilik tabel sebelum FORCE RLS
BEGIN;
SET LOCAL ROLE skema_owner;

SELECT COUNT(*) AS owner_sebelum_force
FROM lab11.pelanggan;

COMMIT;

-- B. Aktifkan FORCE ROW LEVEL SECURITY
ALTER TABLE lab11.pelanggan
FORCE ROW LEVEL SECURITY;

-- Pemilik tabel sekarang ikut terkena RLS
BEGIN;
SET LOCAL ROLE skema_owner;

SELECT COUNT(*) AS owner_setelah_force
FROM lab11.pelanggan;

COMMIT;

-- C. Berikan pg_read_all_data kepada app_analitik
GRANT pg_read_all_data TO app_analitik;

-- Uji pg_read_all_data tanpa BYPASSRLS
BEGIN;
SET LOCAL ROLE app_analitik;

SELECT COUNT(*) AS analitik_tanpa_bypass
FROM lab11.pelanggan;

COMMIT;

-- D. Aktifkan atribut BYPASSRLS
ALTER ROLE app_analitik BYPASSRLS;

-- Uji setelah memiliki BYPASSRLS
BEGIN;
SET LOCAL ROLE app_analitik;

SELECT COUNT(*) AS analitik_dengan_bypass
FROM lab11.pelanggan;

COMMIT;

-- E. Kembalikan atribut BYPASSRLS seperti semula
ALTER ROLE app_analitik NOBYPASSRLS;
