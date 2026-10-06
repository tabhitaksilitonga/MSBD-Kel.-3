SELECT
    status,
    COUNT(*) AS jumlah,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS persen
FROM lab6.event_log
GROUP BY status
ORDER BY status;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM lab6.event_log
WHERE status = 'TERTUNDA';

SET enable_bitmapscan = off;

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

RESET enable_bitmapscan;