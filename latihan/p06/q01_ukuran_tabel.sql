SELECT 
    pg_size_pretty(pg_total_relation_size('lab6.event_log')) AS total_table_size,
    pg_total_relation_size('lab6.event_log') AS total_bytes,
    ROUND(
        pg_total_relation_size('lab6.event_log') / 2000000.0,
        2
    ) AS avg_bytes_per_row;