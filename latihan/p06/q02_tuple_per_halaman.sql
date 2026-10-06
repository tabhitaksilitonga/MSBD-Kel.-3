\timing on
SET max_parallel_workers_per_gather = 0;

WITH per_page AS (
    SELECT 
        split_part(trim(both '()' FROM ctid::text), ',', 1)::bigint AS page_id,
        count(*) AS tuples_count
    FROM lab6.event_log
    GROUP BY 1
)
SELECT 
    min(tuples_count) AS min_tuple_per_page,
    max(tuples_count) AS max_tuple_per_page,
    round(avg(tuples_count), 2) AS rata_rata_tuple_per_halaman,
    count(*) AS total_halaman_terpakai
FROM per_page;

SELECT 
    relpages AS jumlah_halaman,
    reltuples AS estimasi_jumlah_tuple,
    round((reltuples / NULLIF(relpages, 0))::numeric, 2) AS rata_rata_katalog
FROM pg_class
WHERE relname = 'event_log' 
  AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'lab6');