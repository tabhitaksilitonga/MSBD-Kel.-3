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

---

### Jawaban pertanyaan pemahaman langkah 2

**Apa yang terjadi jika bagian volumes: pada layanan PostgreSQL dihapus, kemudian container dihentikan menggunakan docker compose down -v ?**
> kalau bagian volumes: dihapus, data PostgreSQL nya hanya disimpan di lapisan internal. lalu ketika docker compose down -v dijalani, container sama volume yang dibuat docker compose dihapus/hilang permanen. jadinya saat environment dijalani kembali, PostgreSQL melakukan inisialisasi ulang pakai konfigurasi yang ada di docker-compose.yml

**Mengapa pemetaan post ditulis "5432:5432" dan bukan cukup satu angka? Apa yang harus diubah apabila apabila komputer Anda sudah memiliki PostgreSQL lain yang menggunakan port 5432?**
> 5432:5432 dipakai untuk menghubungkan port pada komputer dengan port PostgreSQL di dalam container. Angka pertamanya yang menjadi port pada komputer, sedangkan angka kedua jadi port PostgreSQL di dalam container. Jadi kalau port 5432 udah digunakan oleh PostgreSQL lain, port di komputer bisa diganti, misal menjadi "5433:5432". Jadi PostgreSQL di dalam container tetap pakai port 5432 tapi bisa diakses melalui port 5433

**Apa fungsi block healthcheck? Mengapa healthcheck penting ketika terdapat layanan lain yang bergantung pada basis data?**
> healthcheck fungsinya untuk memastikan layanan di dalam container bener bener siap beroprasi atau tidak. Perintahnya ngecek kesiapan PostgreSQL menerima query secara berkala. itu penting untuk layanan lain yang bergantung pada basis data biar layanannya dinyalakan setelah basis data siap, sehingga mencegah terjadinya kegagalan koneksi pas di startup

**Menyimpan password langsung di dalam docker-compose.yml merupakan praktik yang kurang baik. Sebutkan satu cara yang lebih aman dan jelaskan mengapa hal tersebut penting ketika berkas masuk ke repositori Git.**
> cara yang lebih aman dengan memisahkan kredensial ke dalam berkas lingkungan terpisah, baru memasukkan berkas .env ke dalam aturan .gitignore . ini penting untuk mencegah kebocoran data sensitif saat berkas docker-compose.yml dunggah ke repositori Git publik maupun privat

---

