-- Tabel transaksi kunjungan pasien
CREATE TABLE kunjungan (
    id_kunjungan bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pasien bigint NOT NULL REFERENCES pasien(id_pasien),
    id_jadwal bigint NOT NULL REFERENCES jadwal_praktik(id_jadwal),
    tgl_kunjungan date NOT NULL DEFAULT current_date,
    nomor_antrean integer NOT NULL,
    keluhan text,
    diagnosa text,
    catatan_dokter text,
    status varchar(20) NOT NULL DEFAULT 'menunggu',
    CONSTRAINT ck_status_kunjungan CHECK (status IN ('menunggu', 'diperiksa', 'selesai', 'batal'))
);

-- Entitas asosiatif M:N antara kunjungan dan obat
CREATE TABLE resep (
    id_resep bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_kunjungan bigint NOT NULL REFERENCES kunjungan(id_kunjungan) ON DELETE CASCADE,
    id_obat bigint NOT NULL REFERENCES obat(id_obat),
    jumlah integer NOT NULL CHECK (jumlah > 0),
    aturan_pakai varchar(100) NOT NULL
);