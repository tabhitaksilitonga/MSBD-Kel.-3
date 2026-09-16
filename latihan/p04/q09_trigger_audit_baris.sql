-- 1. Pembuatan Tabel Audit
CREATE TABLE lab4.audit_harga ( 
    audit_id bigserial PRIMARY KEY, 
    film_id integer NOT NULL, 
    harga_lama numeric(5,2), 
    harga_baru numeric(5,2), 
    diubah_oleh text NOT NULL DEFAULT current_user, 
    diubah_pada timestamptz NOT NULL DEFAULT now() 
);

-- 2. Pembuatan Fungsi Trigger
CREATE OR REPLACE FUNCTION lab4.catat_audit_harga()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO lab4.audit_harga (film_id, harga_lama, harga_baru)
    VALUES (NEW.film_id, OLD.rental_rate, NEW.rental_rate);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Pembuatan Trigger Level Baris
CREATE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_audit_harga();
