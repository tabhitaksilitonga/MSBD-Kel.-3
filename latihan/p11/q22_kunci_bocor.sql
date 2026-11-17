-- Diminta: memeriksa kemungkinan kebocoran kunci dan teks terang.
-- Dipilih: memeriksa pg_stat_activity dari session kedua.
-- Alternatif: menganggap kunci aman hanya karena disimpan dalam session tidak dipilih karena query dapat terlihat oleh pemantau aktivitas.

SELECT
    pid,
    usename,
    state,
    query
FROM pg_stat_activity
WHERE datname = current_database()
ORDER BY query_start DESC;
