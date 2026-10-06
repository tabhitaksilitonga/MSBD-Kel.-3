-- ============================================================
-- Q21: REFLEKSI PEMILIHAN JENIS INDEX
-- ============================================================

-- Tidak ada query tambahan untuk Q21.
-- Q21 adalah pertanyaan reflektif; jawaban lengkap ada di
-- draft_kersa.md (ganti XX dengan angka hasil ukur sendiri).
--
-- Ringkasan:
--
-- Partial index   : cocok bila query hanya menyasar sebagian kecil baris
--                   (mis. status GAGAL). Ukuran XX vs index penuh XX.
-- Expression index: cocok untuk predikat berbasis fungsi (mis. lower(email));
--                   predikat query harus sama persis dengan ekspresi index.
-- Covering INCLUDE: menghindari akses heap lewat Index Only Scan;
--                   Heap Fetches XX setelah VACUUM.
-- GIN             : untuk containment pada array/jsonb; efektif bila selektif.
-- BRIN            : kecil sekali untuk tabel besar yang berkorelasi dengan
--                   urutan fisik; ukuran XX vs B-tree XX.
--
-- Semua index mempercepat pembacaan, tetapi menambah biaya penulisan dan
-- ruang penyimpanan. Pilih berdasarkan pola query yang benar-benar sering.

-- Pembersihan akhir: pastikan hanya PK yang tersisa untuk pengukuran
-- anggota lain.
DROP INDEX IF EXISTS lab6.ev_salah_idx,
  lab6.ev_benar_idx,
  lab6.ev_gagal_part_idx,
  lab6.ev_status_full_idx,
  lab6.ev_email_idx,
  lab6.ev_email_lower_idx,
  lab6.ev_cover_plain_idx,
  lab6.ev_cover_idx,
  lab6.ev_tags_gin,
  lab6.ev_payload_gin,
  lab6.ev_payload_gin_path,
  lab6.ev_ts_brin,
  lab6.ev_ts_btree;

SELECT indexname
FROM pg_indexes
WHERE schemaname = 'lab6' AND tablename = 'event_log';
