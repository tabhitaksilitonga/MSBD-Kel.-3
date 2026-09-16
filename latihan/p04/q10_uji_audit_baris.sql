-- Skenario 1: Mengubah harga (Akan memicu audit)
UPDATE lab4.film SET rental_rate = 4.99 WHERE film_id = 1;

-- Skenario 2: Menulis ulang harga yang sama persis (TIDAK memicu audit)
UPDATE lab4.film SET rental_rate = 4.99 WHERE film_id = 1;

-- Skenario 3: Mengubah title saja (TIDAK memicu audit)
UPDATE lab4.film SET title = 'Judul Baru' WHERE film_id = 1;

-- Verifikasi hasil
SELECT * FROM lab4.audit_harga;
