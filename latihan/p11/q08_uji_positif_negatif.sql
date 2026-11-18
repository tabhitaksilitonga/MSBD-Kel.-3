
-- Q8: Uji Positif dan Negatif
-- Permintaan: Membuktikan isolasi data antar-tenant.
-- Keputusan: Menguji akses tenant 1 terhadap datanya sendiri
-- dan data tenant 2.
-- Alternatif ditolak: Menguji hanya akses positif tanpa menguji kebocoran data.

BEGIN;

-- Berperan sebagai pengguna aplikasi laporan
SET LOCAL ROLE app_laporan;

-- Menentukan konteks tenant yang sedang digunakan
SET LOCAL app.tenant = '1';

-- Uji positif: tenant 1 dapat melihat datanya sendiri
SELECT COUNT(*) AS terlihat_tenant1
FROM lab11.pelanggan;

-- Uji negatif: tenant 1 tidak dapat melihat data tenant 2
SELECT COUNT(*) AS harus_nol
FROM lab11.pelanggan
WHERE tenant_id = 2;

COMMIT;
