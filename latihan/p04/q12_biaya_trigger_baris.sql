-- Aktifkan pencatatan waktu di psql
\timing on

-- 1. UPDATE saat trigger AKTIF
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;

-- 2. Matikan trigger
ALTER TABLE lab4.film DISABLE TRIGGER film_audit_harga;

-- 3. UPDATE saat trigger NONAKTIF
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;

-- 4. Nyalakan trigger kembali
ALTER TABLE lab4.film ENABLE TRIGGER film_audit_harga;

\timing off
