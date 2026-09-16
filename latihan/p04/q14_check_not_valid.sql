UPDATE lab4.film SET rental_rate = -1.00 WHERE film_id = 1;

ALTER TABLE lab4.film
ADD CONSTRAINT film_rental_rate_non_negatif
CHECK (rental_rate >= 0) NOT VALID;

SELECT conname, convalidated
FROM pg_constraint
WHERE conname = 'film_rental_rate_non_negatif';

ALTER TABLE lab4.film VALIDATE CONSTRAINT film_rental_rate_non_negatif;

UPDATE lab4.film SET rental_rate = 0.99 WHERE film_id = 1;

ALTER TABLE lab4.film VALIDATE CONSTRAINT film_rental_rate_non_negatif;

SELECT conname, convalidated
FROM pg_constraint
WHERE conname = 'film_rental_rate_non_negatif';