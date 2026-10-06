DROP TABLE IF EXISTS lab6.event_log_noidx;
DROP TABLE IF EXISTS lab6.event_log_5idx;

CREATE TABLE lab6.event_log_noidx (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer NOT NULL,
    terjadi_pada timestamptz NOT NULL,
    status text NOT NULL,
    wilayah text NOT NULL,
    kota text NOT NULL,
    email text NOT NULL,
    idempotency_key uuid NOT NULL,
    jumlah numeric(10,2) NOT NULL,
    tags text[] NOT NULL DEFAULT '{}',
    payload jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE lab6.event_log_5idx (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer NOT NULL,
    terjadi_pada timestamptz NOT NULL,
    status text NOT NULL,
    wilayah text NOT NULL,
    kota text NOT NULL,
    email text NOT NULL,
    idempotency_key uuid NOT NULL,
    jumlah numeric(10,2) NOT NULL,
    tags text[] NOT NULL DEFAULT '{}',
    payload jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX q27_idx_1
ON lab6.event_log_5idx (customer_id);

CREATE INDEX q27_idx_2
ON lab6.event_log_5idx (terjadi_pada);

CREATE INDEX q27_idx_3
ON lab6.event_log_5idx (status);

CREATE INDEX q27_idx_4
ON lab6.event_log_5idx (wilayah);

CREATE INDEX q27_idx_5
ON lab6.event_log_5idx (email);

\timing on

-- PERCOBAAN 1
TRUNCATE lab6.event_log_noidx;
TRUNCATE lab6.event_log_5idx;

INSERT INTO lab6.event_log_noidx
(customer_id, terjadi_pada, status, wilayah, kota, email,
 idempotency_key, jumlah, tags, payload)
SELECT
    (random()*59999)::int+1,
    timestamptz '2025-01-01 00:00+07' + (g * interval '13 second'),
    CASE
        WHEN g%50=0 THEN 'GAGAL'
        WHEN g%7=0 THEN 'TERTUNDA'
        ELSE 'SUKSES'
    END,
    (ARRAY['SUMUT','JABAR','JATIM','BALI','PAPUA'])[(g%5)+1],
    'KOTA-' || ((g%9)+1),
    'q27_noidx_' || g || '@contoh.ac.id',
    gen_random_uuid(),
    round((random()*900+10)::numeric,2),
    ARRAY['kanal:'||(g%4),'sumber:'||(g%3)],
    jsonb_build_object('kanal',g%4,'perangkat',g%6,'promo',(g%25=0))
FROM generate_series(1,200000) AS s(g);

INSERT INTO lab6.event_log_5idx
(customer_id, terjadi_pada, status, wilayah, kota, email,
 idempotency_key, jumlah, tags, payload)
SELECT
    (random()*59999)::int+1,
    timestamptz '2025-01-01 00:00+07' + (g * interval '13 second'),
    CASE
        WHEN g%50=0 THEN 'GAGAL'
        WHEN g%7=0 THEN 'TERTUNDA'
        ELSE 'SUKSES'
    END,
    (ARRAY['SUMUT','JABAR','JATIM','BALI','PAPUA'])[(g%5)+1],
    'KOTA-' || ((g%9)+1),
    'q27_5idx_' || g || '@contoh.ac.id',
    gen_random_uuid(),
    round((random()*900+10)::numeric,2),
    ARRAY['kanal:'||(g%4),'sumber:'||(g%3)],
    jsonb_build_object('kanal',g%4,'perangkat',g%6,'promo',(g%25=0))
FROM generate_series(1,200000) AS s(g);

-- PERCOBAAN 2
TRUNCATE lab6.event_log_noidx;
TRUNCATE lab6.event_log_5idx;

INSERT INTO lab6.event_log_noidx
(customer_id, terjadi_pada, status, wilayah, kota, email,
 idempotency_key, jumlah, tags, payload)
SELECT
    (random()*59999)::int+1,
    timestamptz '2025-01-01 00:00+07' + (g * interval '13 second'),
    CASE
        WHEN g%50=0 THEN 'GAGAL'
        WHEN g%7=0 THEN 'TERTUNDA'
        ELSE 'SUKSES'
    END,
    (ARRAY['SUMUT','JABAR','JATIM','BALI','PAPUA'])[(g%5)+1],
    'KOTA-' || ((g%9)+1),
    'q27_noidx_' || g || '@contoh.ac.id',
    gen_random_uuid(),
    round((random()*900+10)::numeric,2),
    ARRAY['kanal:'||(g%4),'sumber:'||(g%3)],
    jsonb_build_object('kanal',g%4,'perangkat',g%6,'promo',(g%25=0))
FROM generate_series(1,200000) AS s(g);

INSERT INTO lab6.event_log_5idx
(customer_id, terjadi_pada, status, wilayah, kota, email,
 idempotency_key, jumlah, tags, payload)
SELECT
    (random()*59999)::int+1,
    timestamptz '2025-01-01 00:00+07' + (g * interval '13 second'),
    CASE
        WHEN g%50=0 THEN 'GAGAL'
        WHEN g%7=0 THEN 'TERTUNDA'
        ELSE 'SUKSES'
    END,
    (ARRAY['SUMUT','JABAR','JATIM','BALI','PAPUA'])[(g%5)+1],
    'KOTA-' || ((g%9)+1),
    'q27_5idx_' || g || '@contoh.ac.id',
    gen_random_uuid(),
    round((random()*900+10)::numeric,2),
    ARRAY['kanal:'||(g%4),'sumber:'||(g%3)],
    jsonb_build_object('kanal',g%4,'perangkat',g%6,'promo',(g%25=0))
FROM generate_series(1,200000) AS s(g);

-- PERCOBAAN 3
TRUNCATE lab6.event_log_noidx;
TRUNCATE lab6.event_log_5idx;

INSERT INTO lab6.event_log_noidx
(customer_id, terjadi_pada, status, wilayah, kota, email,
 idempotency_key, jumlah, tags, payload)
SELECT
    (random()*59999)::int+1,
    timestamptz '2025-01-01 00:00+07' + (g * interval '13 second'),
    CASE
        WHEN g%50=0 THEN 'GAGAL'
        WHEN g%7=0 THEN 'TERTUNDA'
        ELSE 'SUKSES'
    END,
    (ARRAY['SUMUT','JABAR','JATIM','BALI','PAPUA'])[(g%5)+1],
    'KOTA-' || ((g%9)+1),
    'q27_noidx_' || g || '@contoh.ac.id',
    gen_random_uuid(),
    round((random()*900+10)::numeric,2),
    ARRAY['kanal:'||(g%4),'sumber:'||(g%3)],
    jsonb_build_object('kanal',g%4,'perangkat',g%6,'promo',(g%25=0))
FROM generate_series(1,200000) AS s(g);

INSERT INTO lab6.event_log_5idx
(customer_id, terjadi_pada, status, wilayah, kota, email,
 idempotency_key, jumlah, tags, payload)
SELECT
    (random()*59999)::int+1,
    timestamptz '2025-01-01 00:00+07' + (g * interval '13 second'),
    CASE
        WHEN g%50=0 THEN 'GAGAL'
        WHEN g%7=0 THEN 'TERTUNDA'
        ELSE 'SUKSES'
    END,
    (ARRAY['SUMUT','JABAR','JATIM','BALI','PAPUA'])[(g%5)+1],
    'KOTA-' || ((g%9)+1),
    'q27_5idx_' || g || '@contoh.ac.id',
    gen_random_uuid(),
    round((random()*900+10)::numeric,2),
    ARRAY['kanal:'||(g%4),'sumber:'||(g%3)],
    jsonb_build_object('kanal',g%4,'perangkat',g%6,'promo',(g%25=0))
FROM generate_series(1,200000) AS s(g);