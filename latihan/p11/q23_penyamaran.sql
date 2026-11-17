-- Diminta: membuat tampilan data pelanggan tersamar untuk app_analitik.
-- Dipilih: VIEW dengan security_barrier agar analis hanya melihat data yang telah disamarkan.
-- Alternatif: memberikan akses langsung ke tabel asli tidak dipilih karena membuka data sensitif.

REVOKE pg_read_all_data FROM app_analitik;

CREATE OR REPLACE VIEW lab11.v_pelanggan_samar
WITH (security_barrier = true) AS
SELECT
    id,
    tenant_id,
    left(nama, 1) ||
        repeat('*', greatest(length(nama) - 1, 1)) AS nama,
    'xxxxxxxxxxxx' || right(nik, 4) AS nik,
    regexp_replace(surel, '^[^@]+', '****') AS surel,
    date_trunc('year', lahir)::date AS lahir_tahun,
    kota,
    round(saldo, -5) AS saldo_bulat
FROM lab11.pelanggan;

REVOKE ALL ON lab11.pelanggan FROM app_analitik;

GRANT SELECT ON lab11.v_pelanggan_samar TO app_analitik;

-- Uji akses langsung (diharapkan ditolak)
SET ROLE app_analitik;

SELECT * FROM lab11.pelanggan LIMIT 5;

RESET ROLE;

-- Uji akses melalui view (diharapkan berhasil)
SET ROLE app_analitik;

SELECT * FROM lab11.v_pelanggan_samar LIMIT 5;

RESET ROLE;
