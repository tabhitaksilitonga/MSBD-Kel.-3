SELECT f.title, c.name AS kategori, f.rental_rate,
       ROW_NUMBER() OVER w AS row_number,
       RANK() OVER w AS rank,
       DENSE_RANK() OVER w AS dense_rank
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WINDOW w AS (
    PARTITION BY c.category_id
    ORDER BY f.rental_rate DESC
)
ORDER BY c.name, f.rental_rate DESC;