DROP VIEW lab4.film;

ALTER TABLE lab4.film_data DROP COLUMN rental_rate;

CREATE VIEW lab4.film AS
SELECT
    fd.film_id, fd.title, fd.description, fd.release_year, fd.language_id,
    fd.rental_duration, fd.replacement_cost, fd.rating, fd.last_update,
    fd.special_features, fd.fulltext,
    hf.harga AS rental_rate
FROM lab4.film_data fd
LEFT JOIN lab4.harga_film hf
    ON hf.film_id = fd.film_id AND hf.wilayah = 'ID' AND hf.berlaku @> CURRENT_DATE;