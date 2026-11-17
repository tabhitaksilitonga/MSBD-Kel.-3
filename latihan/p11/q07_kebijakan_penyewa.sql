
-- Q7: Kebijakan Penyewa
-- Permintaan: Membatasi akses data berdasarkan tenant.
-- Keputusan: Menggunakan policy RLS dengan app.tenant.
-- Alternatif ditolak: Memberikan akses seluruh data kepada role aplikasi.

-- Policy untuk membaca data tenant sendiri
CREATE POLICY p_tenant_baca
ON lab11.pelanggan
FOR SELECT
TO app_read, app_write
USING (
    tenant_id = NULLIF(current_setting('app.tenant', true), '')::INT
);

-- Policy untuk menambah, mengubah, dan menghapus data tenant sendiri
CREATE POLICY p_tenant_tulis
ON lab11.pelanggan
FOR ALL
TO app_write
USING (
    tenant_id = NULLIF(current_setting('app.tenant', true), '')::INT
)
WITH CHECK (
    tenant_id = NULLIF(current_setting('app.tenant', true), '')::INT
);
