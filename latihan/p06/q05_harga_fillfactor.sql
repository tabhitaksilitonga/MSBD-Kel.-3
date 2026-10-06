SELECT 
    relname,
    pg_size_pretty(pg_relation_size(relid)) AS table_size
FROM pg_stat_user_tables
WHERE relname IN ('hot_penuh','hot_longgar');