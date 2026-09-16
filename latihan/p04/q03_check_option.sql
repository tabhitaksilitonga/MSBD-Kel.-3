DROP VIEW IF EXISTS lab4.film_murah;

CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99
WITH CASCADED CHECK OPTION;

INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating, language_id)
VALUES (9998, 'Film Uji Q3', 4.99, 'G', 1);