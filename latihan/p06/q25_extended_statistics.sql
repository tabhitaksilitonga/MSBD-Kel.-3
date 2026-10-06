CREATE STATISTICS ev_wilayah_kota_stat
    (dependencies, ndistinct)
ON wilayah, kota
FROM lab6.event_log;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM lab6.event_log
WHERE wilayah = 'SUMUT'
  AND kota = 'SUMUT-1';

ANALYZE lab6.event_log;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM lab6.event_log
WHERE wilayah = 'SUMUT'
  AND kota = 'SUMUT-1';