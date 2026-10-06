-- Q28
-- Membandingkan ukuran tabel dan total ukuran tabel beserta index

SELECT
    'event_log_noidx' AS tabel,
    pg_size_pretty(pg_table_size('lab6.event_log_noidx')) AS ukuran_tabel,
    pg_size_pretty(pg_indexes_size('lab6.event_log_noidx')) AS ukuran_index,
    pg_size_pretty(pg_total_relation_size('lab6.event_log_noidx')) AS ukuran_total

UNION ALL

SELECT
    'event_log_5idx' AS tabel,
    pg_size_pretty(pg_table_size('lab6.event_log_5idx')) AS ukuran_tabel,
    pg_size_pretty(pg_indexes_size('lab6.event_log_5idx')) AS ukuran_index,
    pg_size_pretty(pg_total_relation_size('lab6.event_log_5idx')) AS ukuran_total;