SELECT 
    (ctid).block AS page_number,
    COUNT(*) AS tuple_count
FROM lab6.event_log
GROUP BY (ctid).block
ORDER BY page_number
LIMIT 10;