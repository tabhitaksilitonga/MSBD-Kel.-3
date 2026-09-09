-- Diminta: seluruh pegawai beserta level kedalaman dan jalur jabatan
--          dari puncak, misalnya "Rina > Bima > Toni".
-- Dipilih: recursive CTE dengan anchor pegawai yang atasan_id IS NULL,
--          karena strukturnya tree dan kedalamannya tidak diketahui
--          di awal.
-- Alternatif: self-join berulang sebanyak perkiraan level maksimum;
--          tidak dipilih karena harus menebak jumlah level dulu.

WITH RECURSIVE hierarki AS (
    SELECT
        pegawai_id,
        nama,
        atasan_id,
        1 AS level,
        nama::text AS jalur
    FROM pegawai
    WHERE atasan_id IS NULL

    UNION ALL

    SELECT
        p.pegawai_id,
        p.nama,
        p.atasan_id,
        h.level + 1,
        h.jalur || ' > ' || p.nama
    FROM pegawai p
    JOIN hierarki h ON p.atasan_id = h.pegawai_id
)
SELECT pegawai_id, nama, level, jalur
FROM hierarki
ORDER BY level, jalur;