WITH harian AS (
    SELECT payment_date::date AS tanggal,
           SUM(amount) AS omzet
    FROM payment
    GROUP BY payment_date::date
)
SELECT tanggal,
       omzet,
       LAG(omzet, 1, 0) OVER (ORDER BY tanggal) AS omzet_sebelumnya,
       omzet - LAG(omzet, 1, 0) OVER (ORDER BY tanggal) AS selisih,
       CASE
           WHEN LAG(omzet, 1, 0) OVER (ORDER BY tanggal) = 0 THEN NULL
           ELSE ROUND(
               (omzet - LAG(omzet, 1, 0) OVER (ORDER BY tanggal))
               / LAG(omzet, 1, 0) OVER (ORDER BY tanggal) * 100, 2
           )
       END AS perubahan_persen
FROM harian
ORDER BY tanggal;