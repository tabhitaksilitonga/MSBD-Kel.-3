CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE lab4.harga_film (
    harga_film_id bigserial PRIMARY KEY,
    film_id integer NOT NULL REFERENCES lab4.film (film_id),
    wilayah text NOT NULL,
    harga numeric(5,2) NOT NULL CHECK (harga >= 0),
    berlaku daterange NOT NULL,
    EXCLUDE USING gist (film_id WITH =, wilayah WITH =, berlaku WITH &&)
);

INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
VALUES (1, 'ID', 5.99, daterange('2026-01-01', '2026-04-01'));

INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
VALUES (1, 'ID', 6.99, daterange('2026-02-15', '2026-05-01'));

INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
VALUES (1, 'US', 4.99, daterange('2026-02-15', '2026-05-01'));