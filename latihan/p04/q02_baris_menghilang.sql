INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating, language_id)
VALUES (9999, 'Film Uji Q2', 4.99, 'G', 1);

SELECT 'View film_murah' AS sumber_data, COUNT(*) AS jumlah_baris 
FROM lab4.film_murah WHERE title = 'Film Uji Q2'
UNION ALL
SELECT 'Tabel dasar film' AS sumber_data, COUNT(*) AS jumlah_baris 
FROM lab4.film WHERE title = 'Film Uji Q2';