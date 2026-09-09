(
    SELECT 
        i.film_id, 
        'Ada di Inventory, Tidak Ada di Rental' AS penanda_arah
    FROM inventory i
    EXCEPT
    SELECT 
        i.film_id, 
        'Ada di Inventory, Tidak Ada di Rental' AS penanda_arah
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
)
UNION ALL
(
    SELECT 
        i.film_id, 
        'Ada di Rental, Tidak Ada di Inventory' AS penanda_arah
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    EXCEPT
    SELECT 
        i.film_id, 
        'Ada di Rental, Tidak Ada di Inventory' AS penanda_arah
    FROM inventory i
);
