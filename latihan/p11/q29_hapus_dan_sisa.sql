-- Diminta: Jalankan satu permintaan hapus, hapus transaksi lalu pelanggan. Hitung tempat data masih ditemukan.
-- Dipilih: Menghapus secara terurut tanpa CASCADE untuk mengamankan rekam jejak, lalu menggunakan kueri validasi sisa tabel.
-- Alternatif: Membiarkan data dengan status "is_deleted = true" (Soft delete), tapi ditolak karena menyalahi asas pemusnahan data pribadi di UU PDP.

INSERT INTO lab11.permintaan_hapus (pelanggan_id, alasan) VALUES (12, 'Cabut persetujuan');
DELETE FROM lab11.transaksi WHERE pelanggan_id = 12;
DELETE FROM lab11.pelanggan WHERE id = 12;

SELECT count(*) AS sisa_tabel_utama FROM lab11.pelanggan WHERE id IN (12, 13);
SELECT count(*) AS sisa_transaksi FROM lab11.transaksi WHERE pelanggan_id IN (12, 13);
SELECT count(*) AS sisa_jejak_audit FROM lab11.jejak_audit WHERE kunci = 12;