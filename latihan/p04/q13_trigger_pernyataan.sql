-- 1. Fungsi trigger untuk eksekusi massal
CREATE OR REPLACE FUNCTION lab4.catat_audit_massal()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO lab4.audit_harga (film_id, harga_lama, harga_baru)
    SELECT b.film_id, l.rental_rate, b.rental_rate
    FROM baru b
    JOIN lama l ON b.film_id = l.film_id
    WHERE l.rental_rate IS DISTINCT FROM b.rental_rate;
    
    RETURN NULL; -- Statement level trigger wajib me-return NULL
END;
$$ LANGUAGE plpgsql;

-- 2. Trigger Statement dengan REFERENCING
CREATE TRIGGER film_audit_harga_massal 
AFTER UPDATE ON lab4.film 
REFERENCING OLD TABLE AS lama NEW TABLE AS baru 
FOR EACH STATEMENT 
EXECUTE FUNCTION lab4.catat_audit_massal();

