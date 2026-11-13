UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;

ALTER TYPE lab5.rental_status
ADD VALUE 'EXPIRED';

UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;

SELECT rental_id, status
FROM lab5.rental_tx
WHERE rental_id = 1;