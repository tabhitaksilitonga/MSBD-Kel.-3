SELECT 
    n.data ->> 'nomor_transaksi' AS nomor_transaksi,
    k.value ->> 'jenis' AS jenis_kontak,
    k.value ->> 'nomor' AS nomor_kontak
FROM notifikasi n
LEFT JOIN LATERAL jsonb_array_elements(n.data -> 'kontak') AS k(value) ON true;
