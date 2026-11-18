-- Diminta: Sebagai app_portal penyewa 1, ubah satu baris dan hapus baris uji. Buktikan app_portal tidak bisa membaca/memalsukan audit.
-- Dipilih: SET LOCAL ROLE app_portal, buat data uji lalu hapus, lalu coba SELECT dan INSERT secara manual ke jejak_audit.
-- Alternatif: Menggunakan hak superuser untuk menguji, tidak dipilih karena tidak mensimulasikan koneksi dari sisi pengguna aplikasi yang diretas.

BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

-- Lakukan UPDATE pada ID 3
UPDATE lab11.pelanggan SET kota = 'Medan' WHERE id = 3;

-- Buat baris uji dan hapus (ID 30001)
INSERT INTO lab11.pelanggan (id, tenant_id, nama) VALUES (30001, 1, 'Uji Hapus');
DELETE FROM lab11.pelanggan WHERE id = 30001;

-- BUKTI MENOLAK PEMBACAAN (Buka komentar saat dieksekusi agar galat terlihat)
-- SELECT * FROM lab11.jejak_audit; 

-- BUKTI MENOLAK PEMALSUAN (Buka komentar saat dieksekusi agar galat terlihat)
-- INSERT INTO lab11.jejak_audit (pelaku, aksi) VALUES ('app_portal', 'DELETE');

COMMIT;

-- Lihat hasil suksesnya (dijalankan sebagai postgres/pemilik)
SELECT pelaku, aksi, tabel, kunci FROM lab11.jejak_audit;