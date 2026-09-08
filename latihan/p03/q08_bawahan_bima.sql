WITH RECURSIVE bawahan_bima AS (
    SELECT pegawai_id, nama, atasan_id, 0 AS jarak
    FROM pegawai
    WHERE nama = 'Bima'

    UNION ALL

    SELECT p.pegawai_id, p.nama, p.atasan_id, b.jarak + 1
    FROM pegawai p
    JOIN bawahan_bima b ON p.atasan_id = b.pegawai_id
)
SELECT pegawai_id, nama, jarak
FROM bawahan_bima
WHERE jarak > 0
ORDER BY jarak, nama;