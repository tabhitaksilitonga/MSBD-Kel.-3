WITH harian AS (
    SELECT payment_date::date AS tanggal,
           SUM(amount) AS omzet
    FROM payment
    GROUP BY payment_date::date
),
rows_data AS (
    SELECT tanggal,
           SUM(omzet) OVER (
               ORDER BY tanggal
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS kumulatif_rows,
           AVG(omzet) OVER (
               ORDER BY tanggal
               ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ) AS rata_rows
    FROM harian
),
range_data AS (
    SELECT tanggal,
           SUM(omzet) OVER (ORDER BY tanggal) AS kumulatif_range,
           AVG(omzet) OVER (ORDER BY tanggal) AS rata_range
    FROM harian
)
SELECT r.tanggal,
       r.kumulatif_rows,
       g.kumulatif_range,
       r.rata_rows,
       g.rata_range
FROM rows_data r
JOIN range_data g USING (tanggal)
WHERE r.kumulatif_rows IS DISTINCT FROM g.kumulatif_range
   OR r.rata_rows IS DISTINCT FROM g.rata_range
ORDER BY r.tanggal;