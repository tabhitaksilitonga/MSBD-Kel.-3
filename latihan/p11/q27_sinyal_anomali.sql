-- Diminta: Tulis tiga query sinyal anomali (lonjakan, luar jam kerja, ringkasan). Sebutkan sinyal yang menangkap K2.
-- Dipilih: Deteksi akses luar jam (AT TIME ZONE 'Asia/Jakarta'), ringkasan aksi harian, dan lonjakan modifikasi baris.
-- Alternatif: Menganalisis pg_stat_activity, tapi tidak dipilih karena datanya tidak permanen untuk keluhan log historis.

-- 1. Sinyal Akses di Luar Jam Kerja (18:00 - 06:00 WIB)
SELECT pelaku, aksi, waktu AT TIME ZONE 'Asia/Jakarta' AS waktu_lokal
FROM lab11.jejak_audit
WHERE EXTRACT(HOUR FROM waktu AT TIME ZONE 'Asia/Jakarta') NOT BETWEEN 6 AND 18;

-- 2. Sinyal Ringkasan Aksi Per Tabel
SELECT tabel, aksi, COUNT(*) AS jumlah
FROM lab11.jejak_audit
GROUP BY tabel, aksi;

-- 3. Sinyal Lonjakan Baris Per Peran (Bisa dimodifikasi untuk SELECT log jika RLS tembus, walau di lab ini log terbatas di UPDATE/DELETE)
SELECT pelaku, COUNT(*) AS lonjakan_aktivitas
FROM lab11.jejak_audit
GROUP BY pelaku
HAVING COUNT(*) > 100;