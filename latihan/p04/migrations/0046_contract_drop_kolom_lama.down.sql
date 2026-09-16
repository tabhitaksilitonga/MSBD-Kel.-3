DROP VIEW lab4.film;
ALTER TABLE lab4.film_data ADD COLUMN rental_rate numeric(4,2);
CREATE VIEW lab4.film AS SELECT fd.*, hf.harga AS rental_rate_baru
FROM lab4.film_data fd
LEFT JOIN lab4.harga_film hf ON hf.film_id = fd.film_id AND hf.wilayah = 'ID' AND hf.berlaku @> CURRENT_DATE;