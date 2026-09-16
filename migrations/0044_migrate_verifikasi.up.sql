DO $$
DECLARE sisa integer;
BEGIN
    SELECT count(*) INTO sisa
    FROM lab4.film f
    WHERE NOT EXISTS (
        SELECT 1 FROM lab4.harga_film h
        WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
    );
    IF sisa > 0 THEN
        RAISE EXCEPTION 'Backfill belum lengkap, sisa % film', sisa;
    END IF;
END $$;