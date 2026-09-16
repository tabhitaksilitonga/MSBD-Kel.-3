CREATE OR REPLACE VIEW lab4.pendapatan_kategori AS
SELECT rating AS kategori, SUM(rental_rate) AS total_pendapatan, COUNT(film_id) AS jumlah_film
FROM lab4.film
GROUP BY rating;

INSERT INTO lab4.pendapatan_kategori (kategori, total_pendapatan, jumlah_film)
VALUES ('PG-13', 150.00, 10);