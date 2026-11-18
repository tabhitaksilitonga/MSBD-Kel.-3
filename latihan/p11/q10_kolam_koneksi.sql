
-- Q10: Kolam Koneksi
-- Permintaan: Mencegah kebocoran konteks tenant pada koneksi bersama.
-- Keputusan: Menggunakan SET LOCAL agar konteks tenant
-- hanya berlaku selama transaksi.
-- Alternatif ditolak: Menggunakan SET biasa karena konteks
-- dapat tertinggal pada koneksi yang digunakan kembali.

-- Simulasi koneksi digunakan oleh Tenant 1
BEGIN;

SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

SELECT
    current_setting('app.tenant', true) AS tenant_aktif,
    COUNT(*) AS jumlah_pelanggan
FROM lab11.pelanggan;

COMMIT;

-- Setelah transaksi selesai, konteks tenant tidak lagi tersimpan.
SELECT
    current_setting('app.tenant', true) AS konteks_setelah_commit;
