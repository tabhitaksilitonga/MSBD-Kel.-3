WITH jumlah_per_kategori AS (
    SELECT c.category_id, c.name AS nama_kategori, COUNT(*) AS jumlah_film
    FROM category c
    JOIN film_category fc ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name
    HAVING COUNT(*) > 60
),
rata_tarif_per_kategori AS (
    SELECT c.category_id, ROUND(AVG(f.rental_rate), 2) AS rata_rata_tarif
    FROM category c
    JOIN film_category fc ON fc.category_id = c.category_id
    JOIN film f ON f.film_id = fc.film_id
    WHERE c.category_id IN (SELECT category_id FROM jumlah_per_kategori)
    GROUP BY c.category_id
)
SELECT j.nama_kategori, j.jumlah_film, r.rata_rata_tarif
FROM jumlah_per_kategori j
JOIN rata_tarif_per_kategori r ON r.category_id = j.category_id
ORDER BY j.jumlah_film DESC;