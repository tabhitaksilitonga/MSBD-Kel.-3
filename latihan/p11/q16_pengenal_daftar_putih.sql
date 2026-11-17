-- Diminta: menunjukkan satu bagian query yang tidak bisa diparameterkan (nama kolom atau arah urut), menanganinya dengan daftar putih tertutup, dan membuktikan nilai di luar daftar ditolak.
-- Dipilih: memetakan masukan pengguna ke kamus KOLOM dan ARAH tertutup sebelum menyusun klausa ORDER BY dan melempar ValueError untuk nilai ilegal.
-- Alternatif: menyisipkan variabel kolom/arah langsung ke string SQL atau memakai placeholder %s untuk nama kolom; tidak dipilih karena %s gagal pada identifier dan penyisipan langsung membuka celah SQL injection.

-- Contoh kueri hasil pemetaan daftar putih yang valid (kolom='nama', arah='naik'):
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

PREPARE urutkan_aman_q16 (text) AS
SELECT id, nama, kota
FROM lab11.pelanggan
WHERE nama ILIKE $1
ORDER BY nama ASC
LIMIT 100;

EXECUTE urutkan_aman_q16('%Pelanggan 12%');
DEALLOCATE urutkan_aman_q16;
ROLLBACK;

/*
BAGIAN QUERY YANG TIDAK BISA DIPARAMETERKAN:
Nama pengenal (identifier) seperti nama kolom pada klausa `ORDER BY` (`nama`, `kota`, `dibuat_pada`) serta kata kunci arah pengurutan (`ASC`, `DESC`). Placeholder parameter (`%s` atau `$1`) di PostgreSQL hanya mengikat nilai literal data, tidak dapat digunakan untuk menggantikan nama kolom atau kata kunci sintaks SQL.

IMPLEMENTASI DAFTAR PUTIH TERTUTUP DI rentan.py:
KOLOM = {"nama": "nama", "kota": "kota", "terbaru": "dibuat_pada"}
ARAH  = {"naik": "ASC", "turun": "DESC"}

if kolom not in KOLOM or arah not in ARAH:
    raise ValueError("parameter pengurutan tidak dikenal")

UJI PENOLAKAN NILAI DI LUAR DAFTAR:
Perintah uji:
python rentan.py "Pelanggan 12" "kota; DROP TABLE lab11.pelanggan--" "naik"

BUKTI KELUARAN GALAT TERMINAL (tempelkan traceback asli terminalmu di bawah ini):
[TEMPEL TRACEBACK ValueError ASLI DI SINI]
ValueError: parameter pengurutan tidak dikenal
*/
