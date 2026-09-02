# Lingkup Sistem dan Kebutuhan Data Klinik Kampus

## Lingkup

| Termasuk | Tidak termasuk |
| :--- | :--- |
| Pendaftaran dan profil pasien (mahasiswa/dosen/staf) | Rawat inap jangka panjang |
| Manajemen jadwal jaga dan kuota harian dokter poli | Sistem penggajian dan remunerasi dokter |
| Pencatatan kunjungan dan rekam medis pemeriksaan | Pengadaan obat skala pabrik/vendor |
| Peresepan obat berdasarkan ketersediaan stok klinik | Integrasi klaim asuransi kesehatan pihak ketiga |

---

## Kebutuhan Data

### KD-01: Registrasi Pasien Kampus
- **Deskripsi**: Mencatat identitas civitas akademika yang berobat ke klinik kampus.
- **Data**: nomor_identitas, nama, jenis_pasien, tgl_lahir, no_telp
- **Aturan**: nomor_identitas unik; jenis_pasien hanya 'Mahasiswa', 'Dosen', atau 'Tendik'
- **Volume**: ±40 transaksi/hari
- **Sumber**: Loket pendaftaran klinik
- **Prioritas**: Wajib

### KD-02: Manajemen Data Poli
- **Deskripsi**: Mengelola unit layanan poli medis di lingkungan kampus.
- **Data**: kode_poli, nama_poli, keterangan
- **Aturan**: kode_poli unik sebagai primary key
- **Volume**: ±6 unit poli
- **Sumber**: Administrasi klinik
- **Prioritas**: Wajib

### KD-03: Manajemen Dokter
- **Deskripsi**: Mengelola data dokter jaga dan penempatan unit poli.
- **Data**: no_str, nama_dokter, no_hp, id_poli
- **Aturan**: no_str unik dan dokter terhubung ke poli yang aktif
- **Volume**: ±15 dokter
- **Sumber**: Kepegawaian klinik
- **Prioritas**: Wajib

### KD-04: Penjadwalan Praktik Dokter
- **Deskripsi**: Mengatur jadwal jaga dokter serta batas kuota pasien per sesi praktik.
- **Data**: id_jadwal, id_dokter, hari, jam_mulai, jam_selesai, kuota_maksimal
- **Aturan**: Jadwal dokter tidak boleh bentrok pada hari dan rentang jam yang sama; kuota maksimal 30 pasien per sesi
- **Volume**: ±30 entri/semester
- **Sumber**: Operasional klinik
- **Prioritas**: Wajib

### KD-05: Pendaftaran Kunjungan Pasien
- **Deskripsi**: Mencatat antrean pasien berobat pada jadwal dokter tertentu.
- **Data**: id_kunjungan, nomor_antrean, id_pasien, id_jadwal, tgl_kunjungan, status
- **Aturan**: Pendaftaran ditolak jika kuota hari tersebut sudah terpenuhi
- **Volume**: ±40 kunjungan/hari
- **Sumber**: Loket pendaftaran klinik
- **Prioritas**: Wajib

### KD-06: Catatan Rekam Medis
- **Deskripsi**: Dokter mencatat hasil anamnesis, diagnosa, dan tindakan medis pasien.
- **Data**: id_kunjungan, keluhan, diagnosa, catatan_dokter
- **Aturan**: Hanya dapat diisi setelah status kunjungan terkonfirmasi
- **Volume**: ±40 catatan/hari
- **Sumber**: Dokter pemeriksa
- **Prioritas**: Wajib

### KD-07: Katalog Persediaan Obat
- **Deskripsi**: Mengelola stok obat-obatan yang tersedia di apotek klinik.
- **Data**: kode_obat, nama_obat, satuan, stok
- **Aturan**: Nilai stok tidak boleh bernilai negatif (stok >= 0)
- **Volume**: ±100 jenis obat
- **Sumber**: Petugas farmasi/apotek
- **Prioritas**: Wajib

### KD-08: Peresepan Obat
- **Deskripsi**: Dokter menerbitkan resep obat untuk pasien berdasarkan hasil diagnosa.
- **Data**: id_resep, id_kunjungan, kode_obat, jumlah, aturan_pakai
- **Aturan**: Jumlah obat yang diresepkan tidak boleh melebihi sisa stok fisik di apotek
- **Volume**: ±80 resep/hari
- **Sumber**: Dokter dan petugas apotek
- **Prioritas**: Wajib