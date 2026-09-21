ALTER TABLE lab4.film ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

DROP INDEX IF EXISTS lab4.idx_film_title_aktif_unique;
CREATE UNIQUE INDEX idx_film_title_aktif_unique 
ON lab4.film (title) 
WHERE deleted_at IS NULL;

INSERT INTO lab4.film (title, rental_rate, deleted_at)
VALUES ('Film Unik Test', 4.99, now());

INSERT INTO lab4.film (title, rental_rate, deleted_at)
VALUES ('Film Unik Test', 4.99, NULL);

INSERT INTO lab4.film (title, rental_rate, deleted_at)
VALUES ('Film Unik Test', 2.99, NULL);