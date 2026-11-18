GRANT SELECT ON lab11.transaksi TO app_write WITH GRANT OPTION;
SET ROLE app_write;
GRANT SELECT ON lab11.transaksi TO app_analitik;
RESET ROLE;

-- 1. Coba cabut tanpa CASCADE (akan memunculkan error dependent privileges exist)
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write;

-- 2. Ulangi dengan CASCADE
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write CASCADE;

-- 3. Verifikasi hak baca masing-masing peran
SELECT has_table_privilege('app_analitik', 'lab11.transaksi', 'SELECT') AS analitik,
       has_table_privilege('app_write', 'lab11.transaksi', 'SELECT') AS app_write;