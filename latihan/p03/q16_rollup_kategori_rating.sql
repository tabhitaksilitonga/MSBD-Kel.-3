SELECT 
    CASE WHEN GROUPING(c.name) = 1 THEN 'SEMUA' ELSE c.name END AS kategori,
    CASE WHEN GROUPING(f.rating) = 1 THEN 'SEMUA' ELSE f.rating::TEXT END AS rating,
    COUNT(f.film_id) AS jumlah_film
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY ROLLUP(c.name, f.rating)
ORDER BY c.name, f.rating;
