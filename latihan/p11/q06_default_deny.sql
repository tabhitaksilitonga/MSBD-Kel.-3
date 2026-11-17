
-- Q6: Default Deny
-- Permintaan: Mengaktifkan RLS pada tabel pelanggan.
-- Keputusan: Menggunakan ENABLE ROW LEVEL SECURITY.
-- Alternatif ditolak: Memberikan akses SELECT tanpa pembatasan tenant.

ALTER TABLE lab11.pelanggan
ENABLE ROW LEVEL SECURITY;

BEGIN;

SET LOCAL ROLE app_laporan;

SELECT COUNT(*) AS sebelum_ada_kebijakan
FROM lab11.pelanggan;

COMMIT;
