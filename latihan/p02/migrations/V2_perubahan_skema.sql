CREATE TABLE kunjungan (
    id_kunjungan bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pasien bigint NOT NULL REFERENCES pasien(id_pasien),
    id_dokter bigint NOT NULL REFERENCES dokter(id_dokter),
    tanggal_kunjungan date NOT NULL DEFAULT current_date,
    keluhan text NOT NULL,
    diagnosis text,
    status varchar(20) NOT NULL DEFAULT 'selesai'
        CHECK (status IN ('menunggu', 'diperiksa', 'selesai'))
);

CREATE TABLE resep (
    id_resep bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_kunjungan bigint NOT NULL UNIQUE REFERENCES kunjungan(id_kunjungan),
    tanggal_resep date NOT NULL DEFAULT current_date
);

CREATE TABLE detail_resep (
    id_resep bigint NOT NULL REFERENCES resep(id_resep),
    id_obat bigint NOT NULL REFERENCES obat(id_obat),
    jumlah integer NOT NULL CHECK (jumlah > 0),
    aturan_pakai varchar(150) NOT NULL,
    PRIMARY KEY (id_resep, id_obat)
);