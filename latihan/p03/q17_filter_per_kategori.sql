-- Versi Agregat FILTER
SELECT 
    c.name AS kategori,
    COUNT(f.film_id) AS total_film,
    COUNT(f.film_id) FILTER (WHERE f.rating = 'G') AS total_g,
    COUNT(f.film_id) FILTER (WHERE f.rating = 'PG-13') AS total_pg13,
    AVG(f.length) FILTER (WHERE f.length > 90) AS rata_rata_durasi_lebih_90
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name;

-- Versi CASE WHEN
SELECT 
    c.name AS kategori,
    COUNT(f.film_id) AS total_film,
    SUM(CASE WHEN f.rating = 'G' THEN 1 ELSE 0 END) AS total_g,
    SUM(CASE WHEN f.rating = 'PG-13' THEN 1 ELSE 0 END) AS total_pg13,
    AVG(CASE WHEN f.length > 90 THEN f.length ELSE NULL END) AS rata_rata_durasi_lebih_90
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name;
