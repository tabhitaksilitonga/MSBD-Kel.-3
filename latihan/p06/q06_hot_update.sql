DROP TABLE IF EXISTS lab6.hot_test;

CREATE TABLE lab6.hot_test
(LIKE lab6.event_log INCLUDING ALL);

INSERT INTO lab6.hot_test
SELECT *
FROM lab6.event_log
LIMIT 100000;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'hot_test';

SELECT pg_stat_reset();

UPDATE lab6.hot_test
SET payload = jsonb_build_object('test','update');

SELECT 
    relname,
    n_tup_upd,
    n_tup_hot_upd
FROM pg_stat_user_tables
WHERE relname = 'hot_test';

CREATE INDEX idx_hot_status
ON lab6.hot_test(status);

SELECT pg_stat_reset();

UPDATE lab6.hot_test
SET status = 'GAGAL';

SELECT 
    relname,
    n_tup_upd,
    n_tup_hot_upd
FROM pg_stat_user_tables
WHERE relname = 'hot_test';