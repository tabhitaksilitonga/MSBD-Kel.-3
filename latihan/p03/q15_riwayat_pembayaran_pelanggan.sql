SELECT customer_id,
       payment_id,
       payment_date,
       amount,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY payment_date, payment_id
       ) AS urutan_pembayaran,
       payment_date::date
       - LAG(payment_date::date) OVER (
           PARTITION BY customer_id
           ORDER BY payment_date, payment_id
       ) AS jarak_hari,
       SUM(amount) OVER (
           PARTITION BY customer_id
       ) AS total_belanja
FROM payment
ORDER BY customer_id, payment_date, payment_id;