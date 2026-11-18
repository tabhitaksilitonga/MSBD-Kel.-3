-- Diminta: membuat laporan_kota_rentan dan laporan_kota_aman dari materi, menyimpan nilai berbahaya lewat INSERT aman, memanggil keduanya, dan menjelaskan mengapa pertahanan di pintu masuk tidak menolong.
-- Dipilih: mendemonstrasikan second-order SQL injection lewat dynamic SQL tanpa USING pada laporan_kota_rentan versus parameterisasi USING pada laporan_kota_aman.
-- Alternatif: hanya mengandalkan validasi/parameterisasi saat INSERT tanpa mengamankan EXECUTE dinamis di dalam fungsi; tidak dipilih karena data tersimpan tetap memicu injeksi saat dibaca ulang.

BEGIN;

-- 1. Fungsi laporan rentan (menggabungkan nilai dari tabel langsung ke string EXECUTE)
CREATE OR REPLACE FUNCTION lab11.laporan_kota_rentan(p_pelanggan_id int)
RETURNS TABLE(kota text, jumlah bigint)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nilai text;
BEGIN
    SELECT p.kota INTO v_nilai
    FROM lab11.pelanggan p
    WHERE p.id = p_pelanggan_id;

    -- RENTAN: nilai yang diambil dari tabel digabung mentah menjadi kode SQL
    RETURN QUERY EXECUTE
        'SELECT kota, count(*) FROM lab11.pelanggan WHERE kota = ''' || v_nilai || ''' GROUP BY kota';
END;
$$;

-- 2. Fungsi laporan aman (menggunakan parameter terikat $1 via klausa USING)
CREATE OR REPLACE FUNCTION lab11.laporan_kota_aman(p_pelanggan_id int)
RETURNS TABLE(kota text, jumlah bigint)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nilai text;
BEGIN
    SELECT p.kota INTO v_nilai
    FROM lab11.pelanggan p
    WHERE p.id = p_pelanggan_id;

    -- AMAN: nilai dari tabel dikirim lewat USING sebagai parameter literal
    RETURN QUERY EXECUTE
        'SELECT kota, count(*) FROM lab11.pelanggan WHERE kota = $1 GROUP BY kota'
        USING v_nilai;
END;
$$;

-- 3. Simpan nilai berbahaya lewat jalur INSERT yang aman (berparameter / literal ter-escape):
SET LOCAL app.tenant = '1';
PREPARE simpan_aman (int, int, text, text) AS
INSERT INTO lab11.pelanggan (id, tenant_id, nama, kota)
VALUES ($1, $2, $3, $4);

EXECUTE simpan_aman(999991, 1, 'Uji Second Order', $payload$Medan' OR '1'='1$payload$);
DEALLOCATE simpan_aman;

-- 4. Panggil kedua fungsi laporan dan bandingkan hasilnya:
SELECT * FROM lab11.laporan_kota_rentan(999991);
SELECT * FROM lab11.laporan_kota_aman(999991);

-- Rollback agar data penyewa tetap bersih dan tidak merusak percobaan lain:
ROLLBACK;

/*
BUKTI KELUARAN PSQL (tempelkan output asli psql di bawah ini):
[TEMPEL OUTPUT ASLI KEDUA PEMANGGILAN FUNGSI DI SINI]

PERBANDINGAN HASIL & PENJELASAN:
1. Perbandingan hasil:
   - `laporan_kota_rentan(999991)` mengembalikan rekap seluruh kota pada penyewa aktif (bukan hanya kota milik pelanggan 999991) karena payload `Medan' OR '1'='1` yang tersimpan di kolom memecah literal string pada perintah `EXECUTE` dan mengubah kondisi `WHERE` menjadi selalu benar.
   - `laporan_kota_aman(999991)` hanya mengembalikan 1 baris (yaitu baris dengan nilai harfiah kota `Medan' OR '1'='1`) karena `USING v_nilai` memperlakukan nilai dari tabel sebagai data parameter `$1`.
2. Mengapa pertahanan di pintu masuk (saat INSERT) tidak menolong:
   Pada second-order SQL injection, jalur masuk pertama (`INSERT` berparameter) memang bekerja aman karena menyimpan payload sebagai teks biasa di dalam tabel tanpa mengeksekusinya. Masalah muncul pada tahap kedua ketika fungsi internal basis data membaca kembali data tersebut dan menyusunnya ke dalam perintah `EXECUTE` dinamis tanpa `USING` — mengubah data yang tadinya pasif menjadi kode SQL aktif.
*/
