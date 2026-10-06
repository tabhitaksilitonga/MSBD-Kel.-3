SELECT 
    attname,
    attstorage
FROM pg_attribute
WHERE attrelid = 'lab6.event_log'::regclass
AND attnum > 0;
