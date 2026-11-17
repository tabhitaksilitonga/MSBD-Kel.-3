REVOKE UPDATE ON lab11.pelanggan FROM skema_owner;
SET ROLE skema_owner;
BEGIN; UPDATE lab11.pelanggan SET kota = kota WHERE id = 1; ROLLBACK; -- ditolak (permission denied)
GRANT UPDATE ON lab11.pelanggan TO skema_owner; -- diberikan kembali oleh pemilik sendiri
BEGIN; UPDATE lab11.pelanggan SET kota = kota WHERE id = 1; ROLLBACK; -- berhasil (UPDATE 1)
RESET ROLE;