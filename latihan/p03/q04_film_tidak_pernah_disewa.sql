SELECT
    f.film_id,
    f.title
FROM film f
WHERE f.film_id NOT IN (
    SELECT i.film_id
    FROM inventory i
    JOIN rental r
        ON r.inventory_id = i.inventory_id
)
ORDER BY f.film_id;


-- Pendekatan 2: NOT EXISTS

SELECT
    f.film_id,
    f.title
FROM film f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory i
    JOIN rental r
        ON r.inventory_id = i.inventory_id
    WHERE i.film_id = f.film_id
)
ORDER BY f.film_id;