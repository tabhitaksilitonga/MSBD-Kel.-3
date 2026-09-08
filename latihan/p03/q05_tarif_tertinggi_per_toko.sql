SELECT DISTINCT
    s.store_id,
    f.film_id,
    f.title,
    f.rental_rate
FROM store s
JOIN inventory i
    ON i.store_id = s.store_id
JOIN film f
    ON f.film_id = i.film_id
WHERE f.rental_rate = (
    SELECT MAX(f2.rental_rate)
    FROM inventory i2
    JOIN film f2
        ON f2.film_id = i2.film_id
    WHERE i2.store_id = s.store_id
)
ORDER BY s.store_id, f.title;