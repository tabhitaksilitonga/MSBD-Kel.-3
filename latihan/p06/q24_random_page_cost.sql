SET max_parallel_workers_per_gather = 0;
SET random_page_cost = 1.1;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM lab6.event_log
WHERE status = 'GAGAL';

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM lab6.event_log
WHERE status = 'TERTUNDA';

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM lab6.event_log
WHERE status = 'SUKSES';

RESET random_page_cost;