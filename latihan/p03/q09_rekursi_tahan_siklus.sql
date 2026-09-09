-- Diminta: buat siklus pada data pegawai, amati Q7, perbaiki query agar
--          tahan siklus, lalu pulihkan data.
-- Dipilih: jalur bertipe array pegawai_id + NOT (... = ANY(...)) sebagai
--          pengaman, karena eksplisit terlihat di query dan tidak
--          bergantung fitur khusus versi Postgres.
-- Alternatif: klausa CYCLE bawaan (PostgreSQL 16+); tidak dipilih
--          sebagai versi utama karena kurang eksplisit untuk dijelaskan.

WITH RECURSIVE hierarki AS (
    SELECT
        pegawai_id, nama, atasan_id, 1 AS level,
        nama::text AS jalur,
        ARRAY[pegawai_id] AS jalur_id
    FROM pegawai
    WHERE atasan_id IS NULL

    UNION ALL

    SELECT
        p.pegawai_id, p.nama, p.atasan_id, h.level + 1,
        h.jalur || ' > ' || p.nama,
        h.jalur_id || p.pegawai_id
    FROM pegawai p
    JOIN hierarki h ON p.atasan_id = h.pegawai_id
    WHERE NOT (p.pegawai_id = ANY(h.jalur_id))
)
SELECT pegawai_id, nama, level, jalur
FROM hierarki
ORDER BY level, jalur;