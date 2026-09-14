CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99;