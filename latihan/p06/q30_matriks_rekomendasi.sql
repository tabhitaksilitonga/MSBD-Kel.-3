SELECT
    'status' AS kolom,
    'GAGAL (2%)' AS kondisi,
    'Gunakan index' AS rekomendasi,
    'Selektivitas tinggi, hanya sebagian kecil baris yang dicari' AS alasan

UNION ALL

SELECT
    'status',
    'TERTUNDA (14%)',
    'Pertimbangkan index',
    'Masih dapat menggunakan Bitmap Index Scan, tetapi manfaat bergantung pada kondisi data dan biaya akses'

UNION ALL

SELECT
    'status',
    'SUKSES (84%)',
    'Tidak diprioritaskan',
    'Sebagian besar tabel memenuhi kondisi sehingga Seq Scan lebih efisien'

UNION ALL

SELECT
    'wilayah + kota',
    'Kombinasi kolom',
    'Gunakan extended statistics',
    'Membantu PostgreSQL memperkirakan jumlah baris dengan lebih akurat ketika kolom saling berkaitan'

UNION ALL

SELECT
    'kolom yang sering INSERT',
    'Banyak index',
    'Batasi jumlah index',
    'Setiap INSERT harus memperbarui index sehingga biaya tulis meningkat';