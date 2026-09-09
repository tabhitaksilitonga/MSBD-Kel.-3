WITH peringkat AS (
    SELECT f.title, c.name AS kategori, f.rental_rate,
           ROW_NUMBER() OVER (
               PARTITION BY c.category_id
               ORDER BY f.rental_rate DESC
           ) AS peringkat
    FROM film f
    JOIN film_category fc ON fc.film_id = f.film_id
    JOIN category c ON c.category_id = fc.category_id
)
SELECT *
FROM peringkat
WHERE peringkat <= 3
ORDER BY kategori, peringkat;