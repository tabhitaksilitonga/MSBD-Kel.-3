CREATE OR REPLACE FUNCTION lab5.total_dibayar(p_rental_id bigint)
RETURNS numeric LANGUAGE sql STABLE AS $$
    SELECT coalesce(sum(amount), 0) 
    FROM lab5.payment_tx 
    WHERE rental_id = p_rental_id;
$$;

SELECT lab5.total_dibayar(1);