CREATE UNIQUE INDEX ux_ringkasan_akses_bulan_kanal
ON lab4.ringkasan_akses (bulan, kanal);

REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;

