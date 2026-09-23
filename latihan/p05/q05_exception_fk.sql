CREATE OR REPLACE PROCEDURE lab5.process_rental_safe(
    p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric
) LANGUAGE plpgsql AS $$
DECLARE v_rental_id bigint;
BEGIN
    INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)
    VALUES (p_customer_id, p_inventory_id, p_staff_id)
    RETURNING rental_id INTO v_rental_id;

    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Gagal: ID Customer, Inventory, atau Staff tidak valid/tidak ditemukan.';
END;
$$;