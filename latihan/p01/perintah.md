## Verifikasi Docker
docker --version
docker compose version
docker run --rm hello-world

## Menjalankan Docker Compose
docker compose up -d
docker compose ps

## Akses PostgreSQL via CLI (psql)
docker compose exec postgres psql -U msbd -d postgres

## Akses PostgreSQL via CLI (psql)
docker compose exec postgres psql -U msbd -d postgres

## Pembuatan Database Pagila & Restore
docker compose exec postgres createdb -U msbd pagila
docker compose exec postgres pg_restore -U msbd -d pagila --no-owner /dump/pagila.dump
docker compose exec postgres psql -U msbd -d pagila -c "\dt"

## Menjalankan Verifikasi SQL
docker compose exec postgres psql -U msbd -d pagila -f /latihan/p01/verifikasi.sql

## Tantangan Tambahan 
-- Dijalankan di dalam psql (pagila=#)
\timing on

CREATE TABLE besar AS
SELECT g AS id, md5(g::text) AS nilai
FROM generate_series(1, 2000000) g;

SELECT * FROM besar WHERE nilai = '827ccb0eea8a706c4c34a16891f84e7b';

CREATE INDEX ON besar(nilai);

SELECT * FROM besar WHERE nilai = '827ccb0eea8a706c4c34a16891f84e7b';