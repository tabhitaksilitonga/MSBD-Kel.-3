# Perintah untuk latihan 1

Prasyarat: Docker dan Docker Compose terinstall, jalankan dari root repositori (e:\\DOCKER\\MSBD-Kel.-3).

Langkah cepat:

1. Start layanan

```powershell
cd e:\\DOCKER\\MSBD-Kel.-3
docker compose up -d
```

2. Cek status layanan dan health

```powershell
docker compose ps
docker inspect --format='{{.State.Health.Status}}' msbd-pg
```

3. Jalankan berkas verifikasi SQL (`latihan/p01/verifikasi.sql`)

Opsi A — copy berkas ke container lalu jalankan:

```powershell
docker cp .\latihan\p01\verifikasi.sql msbd-pg:/verifikasi.sql
docker exec msbd-pg psql -U msbd -d latihan -f /verifikasi.sql
```

Opsi B — pipe langsung dari host:

```powershell
Get-Content .\latihan\p01\verifikasi.sql -Raw | docker exec -i msbd-pg psql -U msbd -d latihan
```

4. Cek keluaran dan troubleshooting singkat

- Jika `psql` gagal: cek `docker logs msbd-pg` untuk pesan error.
- Jika container belum sehat, tunggu beberapa detik lalu ulangi `docker compose ps`.

Penjelasan singkat `verifikasi.sql`:

- Berisi query read-only untuk memastikan PostgreSQL responsive dan melihat tabel yang ada.
- Aman dijalankan di environment latihan.

-- Akhiri

