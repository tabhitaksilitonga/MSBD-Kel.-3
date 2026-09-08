SELECT
    title,
    rental_rate,
    (SELECT AVG(rental_rate) FROM film) AS rata_rata,
    rental_rate - (SELECT AVG(rental_rate) FROM film) AS selisih
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film)
ORDER BY rental_rate DESC;