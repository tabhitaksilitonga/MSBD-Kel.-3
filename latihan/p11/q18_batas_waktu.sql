-- Diminta: memasang statement_timeout = '5s' pada app_portal, menjelaskan mengapa percobaan berbasis pg_sleep menjadi berisik di log, dan mengutip SQLSTATE saat batas waktu terlewati.
-- Dipilih: menetapkan batas waktu eksekusi kueri 5 detik pada level peran aplikasi (ALTER ROLE app_portal SET statement_timeout = '5s').
-- Alternatif: membiarkan statement_timeout default (0 / tak terbatas); tidak dipilih karena memberi ruang bagi serangan time-based blind SQL injection dan penahanan koneksi tanpa batas.

ALTER ROLE app_portal SET statement_timeout = '5s';

-- Verifikasi konfigurasi peran app_portal:
SELECT rolname, rolconfig
FROM pg_roles
WHERE rolname = 'app_portal';

-- Uji simulasi lokal bahwa kueri yang melewati 5 detik dibatalkan dengan SQLSTATE 57014:
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL statement_timeout = '5s';
-- Jalankan perintah berikut untuk melihat galat pembatalan (batalkan/rollback setelah galat muncul):
-- SELECT pg_sleep(6);
ROLLBACK;

/*
BUKTI KELUARAN PSQL & GALAT BATAS WAKTU (tempelkan output asli terminalmu di bawah ini):
[TEMPEL OUTPUT ALTER ROLE, SELECT pg_roles, DAN PESAN ERROR pg_sleep(6) DI SINI]

KUTIPAN SQLSTATE SAAT QUERY MELEWATI BATAS:
- SQLSTATE: `57014` (`query_canceled`)
- Pesan galat PostgreSQL: `ERROR:  canceling statement due to statement timeout`

BAGAIMANA BATAS WAKTU MEMBUAT PERCOBAAN pg_sleep MENJADI BERISIK DI LOG:
Pada serangan time-based blind SQL injection, penyerang menyisipkan fungsi penunda waktu seperti `pg_sleep(10)` untuk menyimpulkan isi data berdasarkan jeda respons aplikasi. Ketika `statement_timeout = '5s'` dipasang pada peran `app_portal`, PostgreSQL memutus paksa setiap percobaan penundaan yang melewati 5 detik dan menulis catatan galat `ERROR: canceling statement due to statement timeout` (`SQLSTATE 57014`) beserta teks kueri lengkapnya ke log server. Munculnya lonjakan entri galat `57014` yang memuat pemanggilan `pg_sleep` membuat upaya probing langsung terlihat mencolok (berisik) pada sistem pemantauan log.
*/
