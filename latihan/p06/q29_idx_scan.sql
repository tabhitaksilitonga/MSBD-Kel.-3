SELECT
    indexrelname AS nama_index,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS ukuran_index
FROM pg_stat_user_indexes
WHERE schemaname = 'lab6'
  AND relname = 'event_log'
ORDER BY indexrelname;