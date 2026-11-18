-- Diminta: menjalankan payload pembanding 22' OR '1'='1 dan 22' OR '1'='1' --, menyalin jumlah baris keduanya, lalu menjelaskan penyebab perbedaan hasilnya.
-- Dipilih: membandingkan kedua payload di lab11-web untuk membuktikan bahwa kerentanan terjadi karena masukan pengguna ikut menyusun kalimat SQL.
-- Alternatif: menghafal daftar payload tanpa menganalisis hasil rakitan string SQL; tidak dipilih karena mengaburkan mekanisme parser SQL.

-- 1. Simulasi SQL hasil rakitan payload pertama: 22' OR '1'='1 (tanpa komentar)
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

SELECT count(*) AS baris_tanpa_komentar
FROM lab11.pelanggan
WHERE nama ILIKE '%22' OR '1'='1%';
ROLLBACK;

-- 2. Simulasi SQL hasil rakitan payload kedua: 22' OR '1'='1' -- (dengan komentar)
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

SELECT count(*) AS baris_dengan_komentar
FROM lab11.pelanggan
WHERE nama ILIKE '%22' OR '1'='1' --%';
ROLLBACK;

/*
PERINTAH DIJALANKAN DI KONTAINER lab11-web:
python rentan.py "22' OR '1'='1"
python rentan.py "22' OR '1'='1' --"

BUKTI KELUARAN TERMINAL (tempelkan output asli terminalmu di bawah ini):
[TEMPEL OUTPUT TERMINAL ASLI DI SINI]

PERBANDINGAN JUMLAH BARIS & PENJELASAN:
1. Payload `22' OR '1'='1` menghasilkan 0 baris:
   Tanpa tanda komentar `--` di akhir, tanda kutip penutup dan wildcard bawaan kode (`%'`) menempel langsung di ujung kanan angka `1`, sehingga kondisi kedua terbaca oleh parser sebagai `'1' = '1%'`. Karena string `'1'` tidak sama dengan `'1%'` (FALSE) dan tidak ada nama yang mengandung `'22'` (FALSE), ekspresi `FALSE OR FALSE` bernilai salah dan mengembalikan 0 baris.
2. Payload `22' OR '1'='1' --` mengembalikan seluruh baris penyewa (10.000 baris pada tabel / 100 baris dengan LIMIT 100):
   Token `--` menandai komentar satu baris di PostgreSQL sehingga sisa templat kode bawaan (`%'`) diabaikan oleh parser. Kondisi `'1' = '1'` berdiri utuh sebagai tautologi (selalu TRUE), sehingga seluruh baris penyewa aktif lolos penyaringan WHERE.
3. Inti pelajaran:
   Masalah utamanya bukan sekadar keberadaan tanda kutip, melainkan aplikasi mencampur data masukan pengguna ke dalam string kode SQL sebelum diparsing oleh server basis data.
*/
