SELECT
    nama_kategori,
    jumlah_film
FROM (
    SELECT
        c.name AS nama_kategori,
        COUNT(*) AS jumlah_film
    FROM category c
    JOIN film_category fc
        ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name
) AS kategori
WHERE jumlah_film > 60
ORDER BY jumlah_film DESC;


-- Pendekatan 2: HAVING

SELECT
    c.name AS nama_kategori,
    COUNT(*) AS jumlah_film
FROM category c
JOIN film_category fc
    ON fc.category_id = c.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(*) > 60
ORDER BY jumlah_film DESC;