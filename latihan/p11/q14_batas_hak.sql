-- Diminta: mengulangi payload injeksi lewat koneksi app_laporan (anggota app_read dan tunduk RLS), mencatat apa yang berubah dan tetap, serta mengaitkannya dengan prinsip hak minimum.
-- Dipilih: menguji payload 22' OR '1'='1' -- menggunakan peran app_laporan untuk mengukur sejauh mana pembatasan hak dan RLS menahan dampak SQL injection.
-- Alternatif: menjalankan koneksi aplikasi memakai pemilik skema (skema_owner) atau superuser; tidak dipilih karena melanggar prinsip least privilege dan melewati RLS.

BEGIN;
SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

-- Uji pembacaan dengan payload injeksi yang sama lewat peran app_laporan:
SELECT count(*) AS total_baris_terbaca_app_laporan
FROM lab11.pelanggan
WHERE nama ILIKE '%22' OR '1'='1' --%';

-- Uji penulisan (harus ditolak karena app_laporan hanya anggota app_read):
-- UPDATE lab11.pelanggan SET kota = 'Medan' WHERE id = 1;
ROLLBACK;

/*
PERINTAH DIJALANKAN DI KONTAINER lab11-web (dengan peran app_laporan):
[TEMPEL PERINTAH & OUTPUT TERMINAL ASLI DI SINI]

CATATAN PERBANDINGAN (APA YANG TETAP vs APA YANG BERUBAH):
1. Apa yang tetap:
   - Kerentanan SQL injection di kode aplikasi tetap berhasil memanipulasi logika klausa WHERE (`'1'='1'`) sehingga membocorkan seluruh baris dalam tabel `lab11.pelanggan` yang terlihat oleh sesi tersebut (10.000 baris), bukan hanya satu nama pelanggan.
2. Apa yang berubah:
   - Cakupan baris yang bocor dibatasi hanya pada penyewa aktif sesi tersebut (maksimal 10.000 baris penyewa 1, bukan seluruh 30.000 baris lintas 3 penyewa) karena `app_laporan` tunduk pada kebijakan Row-Level Security (RLS). Jika `app.tenant` tidak disetel, hasilnya 0 baris.
   - Penyerang tidak dapat mengubah, menambah, atau menghapus data (`INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `DROP`) karena `app_laporan` hanya mewarisi hak baca (`SELECT`) dari `app_read`.

KAITAN DENGAN PRINSIP HAK MINIMUM (LEAST PRIVILEGE) PER TABEL:
- Prinsip hak minimum per tabel membatasi setiap peran hanya pada operasi dan tabel yang mutlak diperlukan. Meskipun lapisan aplikasi memiliki bug SQL injection, kerusakan tetap terisolasi di lapisan basis data: penyerang tidak bisa melintas ke data penyewa lain (ditahan RLS), tidak bisa merusak data (ditahan izin SELECT-only), dan tidak bisa mengakses tabel sensitif lain yang tidak diberikan haknya.
*/
