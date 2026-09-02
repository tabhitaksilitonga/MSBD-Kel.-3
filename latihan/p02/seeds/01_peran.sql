-- File: latihan/p02/seeds/01_peran.sql
-- Keterangan: Seed data untuk peran/klasifikasi entitas
-- Idempoten: aman dijalankan berulang kali

CREATE TABLE IF NOT EXISTS peran (
    kode_peran varchar(10) PRIMARY KEY,
    nama_peran varchar(100) NOT NULL UNIQUE
);

INSERT INTO peran (kode_peran, nama_peran)
VALUES
    ('MHS', 'Mahasiswa'),
    ('DSN', 'Dosen'),
    ('TDK', 'Tendik'),
    ('DKT', 'Dokter')
ON CONFLICT (kode_peran)
DO UPDATE SET
    nama_peran = EXCLUDED.nama_peran;
