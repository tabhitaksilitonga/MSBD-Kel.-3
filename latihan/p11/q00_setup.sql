-- Ekstensi untuk Hashing (Persiapan Q19)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Buat Peran (Sesuai Konsep Lapis Peran)
CREATE ROLE skema_owner NOLOGIN;
CREATE ROLE app_read NOLOGIN;
CREATE ROLE app_write NOLOGIN;
CREATE ROLE app_laporan LOGIN PASSWORD 'laporan123' IN ROLE app_read;
CREATE ROLE app_portal LOGIN PASSWORD 'portal123' IN ROLE app_read, app_write;
CREATE ROLE app_analitik LOGIN;

-- 2. Buat Skema
CREATE SCHEMA lab11 AUTHORIZATION skema_owner;

ALTER DEFAULT PRIVILEGES FOR ROLE skema_owner IN SCHEMA lab11 GRANT SELECT ON TABLES TO app_read;
ALTER DEFAULT PRIVILEGES FOR ROLE skema_owner IN SCHEMA lab11 GRANT INSERT, UPDATE, DELETE ON TABLES TO app_write;

-- Masuk sebagai pemilik untuk membuat tabel
SET ROLE skema_owner;

-- 3. Struktur Tabel
CREATE TABLE lab11.tenant (
    id INT PRIMARY KEY,
    nama VARCHAR(50)
);

CREATE TABLE lab11.pelanggan (
    id INT PRIMARY KEY,
    tenant_id INT REFERENCES lab11.tenant(id),
    nama VARCHAR(100),
    kota VARCHAR(50),
    nik VARCHAR(16),
    surel VARCHAR(100),
    lahir DATE,
    saldo NUMERIC,
    dibuat_pada TIMESTAMP DEFAULT now()
);

CREATE TABLE lab11.akun (
    id INT PRIMARY KEY,
    nama_pengguna VARCHAR(50),
    peran_aplikasi VARCHAR(50),
    status VARCHAR(20),
    kata_sandi VARCHAR(100)
);

CREATE TABLE lab11.transaksi (
    id INT PRIMARY KEY,
    pelanggan_id INT REFERENCES lab11.pelanggan(id),
    jumlah NUMERIC,
    waktu TIMESTAMP DEFAULT now()
);

-- 4. Injeksi Data Deterministik
-- 3 Penyewa
INSERT INTO lab11.tenant (id, nama) VALUES (1, 'Penyewa 1'), (2, 'Penyewa 2'), (3, 'Penyewa 3');

-- 4 Akun (Berdasarkan Q13 Serangan Union)
INSERT INTO lab11.akun (id, nama_pengguna, peran_aplikasi, status, kata_sandi) VALUES
(1, 'sinta', 'operator', 'AKTIF', 'sandi123'),
(2, 'bagas', 'penyelia', 'AKTIF', 'sandi123'),
(3, 'ratna', 'operator', 'AKTIF', 'sandi123'),
(4, 'yusuf', 'auditor', 'AKTIF', 'sandi123');

-- 30.000 Pelanggan (10.000 per tenant)
INSERT INTO lab11.pelanggan (id, tenant_id, nama, kota, nik, surel, lahir, saldo)
SELECT 
    i, 
    ((i - 1) / 10000) + 1, 
    'Pelanggan ' || i, 
    CASE WHEN i % 2 = 0 THEN 'Medan' ELSE 'Jakarta' END,
    '123456789012' || lpad((i % 10000)::text, 4, '0'),
    'user' || i || '@contoh.ac.id',
    '1970-01-01'::DATE + (i % 20000),
    (i % 1000) * 1000.50
FROM generate_series(1, 30000) s(i);

-- 120.000 Transaksi (4 per pelanggan)
INSERT INTO lab11.transaksi (id, pelanggan_id, jumlah)
SELECT 
    i, 
    ((i - 1) / 4) + 1, 
    (i % 100) * 50.00
FROM generate_series(1, 120000) s(i);

RESET ROLE;