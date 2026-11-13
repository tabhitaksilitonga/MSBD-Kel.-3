SELECT count(*) AS sebelum FROM lab5.rental_tx;

CALL lab5.process_rental(1, 1, 1, -4.99);

SELECT count(*) AS sesudah FROM lab5.rental_tx;