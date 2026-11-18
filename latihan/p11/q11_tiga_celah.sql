
-- Q11: Tiga Celah Keamanan RLS
-- Permintaan: Menjelaskan tiga kondisi yang dapat melemahkan RLS.
-- Keputusan: Menggunakan hasil pengujian Q9 sebagai bukti nyata.
-- Alternatif ditolak: Menganggap RLS sudah cukup tanpa konfigurasi
-- role dan pengelolaan konteks tenant yang benar.

-- CELAH 1: Pemilik tabel dapat melewati RLS secara default.
-- Bukti: Q9 menghasilkan 30000 sebelum FORCE dan 0 setelah FORCE.
-- Perbaikan: Aktifkan FORCE ROW LEVEL SECURITY.

-- CELAH 2: Role dengan atribut BYPASSRLS dapat melewati RLS.
-- Bukti: Q9 menghasilkan 30000 ketika app_analitik memiliki BYPASSRLS.
-- Perbaikan: Jangan memberikan BYPASSRLS kepada role aplikasi biasa.

-- CELAH 3: Konteks tenant dapat tertinggal pada koneksi bersama
-- atau ditentukan dari input pengguna yang tidak tepercaya.
-- Bukti: Q10 menunjukkan konteks SET LOCAL kosong setelah COMMIT.
-- Perbaikan: Gunakan SET LOCAL dalam transaksi dan tentukan tenant
-- dari identitas pengguna yang sudah diverifikasi.

-- Bukti tambahan: Periksa status RLS pada tabel pelanggan.
SELECT
    c.relname AS nama_tabel,
    c.relrowsecurity AS rls_aktif,
    c.relforcerowsecurity AS force_rls_aktif
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'lab11'
  AND c.relname = 'pelanggan';
