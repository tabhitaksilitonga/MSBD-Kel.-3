-- File: latihan/p02/seeds/01_peran.sql
-- Keterangan: Seed data untuk peran/klasifikasi entitas

INSERT INTO peran (kode_peran, nama_peran) 
VALUES 
    ('MHS', 'Mahasiswa'),
    ('DSN', 'Dosen'),
    ('TDK', 'Tendik'),
    ('DKT', 'Dokter')
ON CONFLICT (kode_peran) 
DO UPDATE SET 
    nama_peran = EXCLUDED.nama_peran;
