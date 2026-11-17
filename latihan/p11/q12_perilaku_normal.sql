-- Diminta: menjalankan rentan.py dengan satu nama biasa sebagai pembanding, menyalin teks SQL yang tercetak, dan menunjukkan bagian yang berasal dari masukan pengguna.
-- Dipilih: menjalankan python rentan.py "Pelanggan 12" di dalam kontainer lab11-web pada penyewa 1 sebagai baseline perilaku normal.
-- Alternatif: langsung memasukkan payload injeksi tanpa pembanding normal; tidak dipilih karena tidak memperlihatkan perubahan struktur sintaks SQL.

-- Simulasi kueri SQL yang dibentuk oleh rentan.py saat masukan = "Pelanggan 12":
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

SELECT id, nama, kota
FROM lab11.pelanggan
WHERE nama ILIKE '%Pelanggan 12%'
LIMIT 100;
ROLLBACK;

/*
PERINTAH DIJALANKAN DI KONTAINER lab11-web:
python rentan.py "Pelanggan 12"

BUKTI KELUARAN TERMINAL (tempelkan output asli terminalmu di bawah ini):
[TEMPEL OUTPUT TERMINAL ASLI DI SINI - harapkan 365 baris penyewa 1 atau 100 baris karena LIMIT 100]

ANALISIS BAGIAN MASUKAN PENGGUNA:
- Teks SQL yang tercetak:
  SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%Pelanggan 12%' LIMIT 100
- Bagian yang berasal dari masukan pengguna:
  Substring `Pelanggan 12` yang berada di antara wildcard `%...%` di dalam klausa `WHERE nama ILIKE '%Pelanggan 12%'`. Nilai ini disisipkan langsung melalui penggabungan string mentah (string concatenation/interpolation) tanpa pemisahan saluran parameter.
*/
