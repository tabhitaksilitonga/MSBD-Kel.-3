DROP TABLE IF EXISTS lab6.hot_penuh;
DROP TABLE IF EXISTS lab6.hot_longgar;

CREATE TABLE lab6.hot_penuh
(LIKE lab6.event_log INCLUDING ALL)
WITH (fillfactor = 100);

CREATE TABLE lab6.hot_longgar
(LIKE lab6.event_log INCLUDING ALL)
WITH (fillfactor = 80);

INSERT INTO lab6.hot_penuh
SELECT *
FROM lab6.event_log
LIMIT 100000;

INSERT INTO lab6.hot_longgar
SELECT *
FROM lab6.event_log
LIMIT 100000;

UPDATE lab6.hot_penuh
SET payload = jsonb_build_object('test','update');

UPDATE lab6.hot_longgar
SET payload = jsonb_build_object('test','update');

SELECT 
    relname,
    n_tup_upd,
    n_tup_hot_upd
FROM pg_stat_user_tables
WHERE relname IN ('hot_penuh','hot_longgar');