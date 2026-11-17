CREATE TABLE lab11.catatan_postgres (id int);
SELECT has_table_privilege('app_laporan', 'lab11.catatan_postgres', 'SELECT') AS via_postgres;
DROP TABLE lab11.catatan_postgres;