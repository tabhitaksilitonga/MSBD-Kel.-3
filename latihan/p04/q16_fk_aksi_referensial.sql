DROP TABLE IF EXISTS lab4.item_pesanan CASCADE;
DROP TABLE IF EXISTS lab4.pesanan CASCADE;

CREATE TABLE lab4.pesanan (
    pesanan_id serial PRIMARY KEY,
    keterangan text
);

CREATE TABLE lab4.item_pesanan (
    item_id serial PRIMARY KEY,
    pesanan_id int REFERENCES lab4.pesanan(pesanan_id) ON DELETE RESTRICT,
    nama_barang text
);

INSERT INTO lab4.pesanan VALUES (1, 'Pesanan A');
INSERT INTO lab4.item_pesanan VALUES (101, 1, 'Barang 1');

DELETE FROM lab4.pesanan WHERE pesanan_id = 1;

ALTER TABLE lab4.item_pesanan DROP CONSTRAINT item_pesanan_pesanan_id_fkey;
ALTER TABLE lab4.item_pesanan 
ADD CONSTRAINT item_pesanan_pesanan_id_fkey 
FOREIGN KEY (pesanan_id) REFERENCES lab4.pesanan(pesanan_id) ON DELETE CASCADE;

DELETE FROM lab4.pesanan WHERE pesanan_id = 1;
SELECT count(*) FROM lab4.item_pesanan;