-- Q31
-- Dasar numerik rekomendasi index

SELECT
    'GAGAL' AS parameter,
    '2%' AS nilai,
    'Index efektif untuk data dengan selektivitas tinggi' AS kesimpulan

UNION ALL

SELECT
    'TERTUNDA',
    '14%',
    'Masih dapat menggunakan Bitmap Index Scan'

UNION ALL

SELECT
    'SUKSES',
    '84%',
    'Seq Scan lebih sesuai karena sebagian besar baris memenuhi kondisi'

UNION ALL

SELECT
    'Estimasi SUMUT + SUMUT-1 sebelum ANALYZE',
    '8.387 baris',
    'Estimasi kurang akurat'

UNION ALL

SELECT
    'Estimasi SUMUT + SUMUT-1 sesudah ANALYZE',
    '43.868 baris',
    'Estimasi mendekati actual 44.444 baris'

UNION ALL

SELECT
    'INSERT tanpa index',
    '1059.442 ms',
    'Median waktu INSERT 200.000 baris'

UNION ALL

SELECT
    'INSERT dengan 5 index',
    '2720.725 ms',
    'Median waktu INSERT 200.000 baris'

UNION ALL

SELECT
    'Kenaikan waktu INSERT',
    '156.79%',
    'Menunjukkan adanya biaya tambahan pemeliharaan index';