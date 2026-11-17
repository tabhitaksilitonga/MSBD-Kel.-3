-- Diminta: mengubah pemanggilan di rentan.py agar memakai fungsi cari_aman yang berparameter, mengulang payload yang sama, mengutip hasil/galatnya, dan menjelaskan mengapa penyaringan karakter tidak setara.
-- Dipilih: menggunakan parameterized query (%s dengan tuple parameter di psycopg) agar PostgreSQL memisahkan struktur perintah SQL dari nilai data.
-- Alternatif: menyaring atau menghapus karakter berbahaya seperti tanda kutip (') dan komentar (--); tidak dipilih karena mudah dibypass dan merusak data sah.

-- Demonstrasi ekuivalen parameterized query di PostgreSQL (PREPARE / EXECUTE):
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

PREPARE cari_aman_q15 (text) AS
SELECT id, nama, kota
FROM lab11.pelanggan
WHERE nama ILIKE $1
LIMIT 100;

EXECUTE cari_aman_q15('%22'' OR ''1''=''1'' --%');
DEALLOCATE cari_aman_q15;
ROLLBACK;

/*
KODE PERBAIKAN DI rentan.py:
def cari_aman(cur, kata):
    # BENAR: nilai lewat saluran berbeda, tidak pernah menjadi kode
    cur.execute(
        "SELECT id, nama, kota FROM lab11.pelanggan "
        "WHERE nama ILIKE %s LIMIT 100",
        (f"%{kata}%",)
    )
    return cur.fetchall()

PERINTAH DIJALANKAN DI KONTAINER lab11-web:
python rentan.py "22' OR '1'='1' --"

BUKTI KELUARAN TERMINAL (tempelkan output asli terminalmu di bawah ini):
[TEMPEL OUTPUT TERMINAL ASLI DI SINI - harapkan 0 baris ditemukan tanpa galat sintaks]

MENGAPA PENYARINGAN KARAKTER TIDAK MENCAPAI HASIL YANG SAMA:
1. Penyaringan karakter (blacklist) selalu tertinggal dari teknik bypass penyerang (misalnya variasi encoding karakter, injeksi tanpa kutip pada kolom angka, atau injeksi pada klausa ORDER BY).
2. Menghapus atau mengubah karakter tertentu merusak integritas masukan pengguna yang sah (misalnya nama pelanggan yang memang mengandung tanda petik seperti `O'Connor` atau `Ma'ruf`).
3. Sebaliknya, parameterized query memisahkan jalur kompilasi sintaks SQL dari jalur pengiriman nilai data pada protokol basis data; apa pun isi string parameter, parser PostgreSQL selamanya memperlakukannya sebagai nilai literal, bukan instruksi SQL.
*/
