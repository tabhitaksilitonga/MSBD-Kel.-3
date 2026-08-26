# Laporan MSBD Kelompok 3 - Latihan 1

**Nama Anggota:**
- Tabhita Kristy SIlitonga - 251402023 (PM)
- Jevine Jeje Zakarias Simanjuntak - 251402085
- Fadila Lisma Sari - 251402117
- Qairsya Naurel ein Yaliki - 251402120
- Reynald Alvaro Pasaribu - 251402147

---

### Keluaran `docker --version`
Docker version 29.7.2, build a7dcaa6

---

### Keluaran `docker compose version`
Docker Compose version v5.4.0

---

### Keluaran `docker compose ps`
NAME         IMAGE            COMMAND                  SERVICE    CREATED          STATUS                    PORTS
msbd-mongo   mongo:8          "docker-entrypoint.s…"   mongo      30 seconds ago   Up 28 seconds             0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp
msbd-pg      postgres:17      "docker-entrypoint.s…"   postgres   30 seconds ago   Up 28 seconds (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
msbd-redis   redis:7-alpine   "docker-entrypoint.s…"   redis      30 seconds ago   Up 28 seconds             0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp

---

### Keluaran `SELECT version();`
PostgreSQL 17.11 (Debian 17.11-1.pgdg13+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit

---

### Jawaban pertanyaan pemahaman langkah 1

**Apa yang dimaksud dengan Docker Image?**
> ini adalah template yang read only, nanti isinya adalah semua kebutuhan untuk menjalankan sebuah aplikasi, seperti kode program, library, dan konfigurasi. Image ini digunakan sebagai dasar untuk membuat container

**Apa yang dimaksud dengan Container?**
> container inilah wujud nyata/tempat untuk menjalankan aplikasi dari docker image

**Apa fungsi Volume?**
> volume sendiri adalah media penyimpanan data yang bersifat permanen (persistent storage). nah jadi fungsi volume disini untuk menyimpan data dari container agar data tersebut tetap aman dan tidak hilang ketika container dihentikan atau dihapus