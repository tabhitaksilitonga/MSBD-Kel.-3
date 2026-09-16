# Laporan P04 — SQL Lanjutan II
## Materialized View: Q5–Q8 dan Reflektif B

---

## Refleksi A - View dan WITH CHECK OPTION

**1. Sebuah tim menempatkan seluruh akses aplikasi melalui view dengan alasan lebih aman dan lebih rapi. Sebutkan dua keuntungan, dua kerugian, dan satu keadaan konkret ketika pendekatan ini justru mempersulit tim berdasarkan pengamatan Q1–Q4.**
> Keuntungan:
1. lebih aman buat data. view bisa nyembunyiin kolom-kolom sensitif dari tabel asli. jadi, aplikasi atau user cuma bisa akses data yang emang diizinin aja, nggak bisa intip sembarangan.
2. kode aplikasi jadi lebih bersih. query yg tadinya ribet udah dibungkus rapi di view. jadi backend tinggal SELECT simpel aja tanpa perlu mikirin logika database yang ruwet di sisi kode program.
Kerugian:
1. nggak fleksibel buat operasi tulis (INSERT/UPDATE/DELETE). Nggak semua view bisa dimodifikasi datanya secara langsung, apalagi kalau view-nya pakai fungsi agregat atau aturan filter yang ketat.
2. ribet pas maintenance. Kalau struktur tabel aslinya berubah (misal nama kolom diganti atau tabelnya di-drop), view yang bergantung sama tabel itu bakal langsung error dan harus dibenerin manual satu per satu.

Keadaan konkret yang malah mempersulit tim:
misal tim developer disuruh masukin data film baru yang harga sewanya normal (misal 4.99) lewat view film_murah (kayak di Q3). itu pasti langsung ditolak sama database karena melanggar CHECK OPTION atau pas mau input data rekap pendapatan (kayak di Q4), pasti error juga karena view yang pakai GROUP BY emang nggak bisa di-insert langsung. jadinya, developer bakal stuck, mau nggak mau mereka harus bikin trigger INSTEAD OF yang logikanya ribet, atau malah nekat bypass view dan akses tabel dasar langsung. padahal tujuan awal arsitekturnya kan biar aksesnya terpusat dan rapi, eh malah jadi penghambat workflow tim sendiri pas butuh fitur input data yang nggak sesuai sama kriteria view.

## Q5 — Query Dasar Akses

Query dasar digunakan untuk merangkum data `lab4.jejak_akses` berdasarkan bulan dan kanal. Query menghitung jumlah akses dan jumlah film unik.

Hasil query mencakup data dari September 2025 sampai Maret 2026 untuk kanal `android`, `ios`, `kiosk`, dan `web`.

### Timing

- Q5 Query dasar: **[ISI ANGKA TIME Q5 DI SINI]**

## Q6 — Membuat Materialized View

Materialized view dibuat dengan nama `lab4.ringkasan_akses` menggunakan `WITH NO DATA`.

### Error sebelum refresh

```text
ERROR:  materialized view "ringkasan_akses" has not been populated
HINT:  Use the REFRESH MATERIALIZED VIEW command

