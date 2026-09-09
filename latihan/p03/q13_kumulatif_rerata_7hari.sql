WITH harian AS (
    SELECT payment_date::date AS tanggal,
           SUM(amount) AS omzet
    FROM payment
    GROUP BY payment_date::date
)
SELECT tanggal,
       omzet,
       SUM(omzet) OVER (
           ORDER BY tanggal
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS omzet_kumulatif,
       ROUND(
           AVG(omzet) OVER (
               ORDER BY tanggal
               ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ), 2
       ) AS rata_rata_7hari
FROM harian
ORDER BY tanggal;