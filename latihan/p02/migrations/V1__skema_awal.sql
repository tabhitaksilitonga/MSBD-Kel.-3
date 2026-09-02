CREATE TABLE poli (
    id_poli bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nama_poli varchar(100) NOT NULL UNIQUE
);

CREATE TABLE dokter (
    id_dokter bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nama varchar(120) NOT NULL,
    no_str varchar(30) NOT NULL UNIQUE,
    id_poli bigint NOT NULL REFERENCES poli(id_poli)
);

CREATE TABLE pasien (
    id_pasien bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nomor_identitas varchar(20) NOT NULL UNIQUE,
    nama varchar(120) NOT NULL,
    jenis_pasien varchar(20) NOT NULL
        CHECK (jenis_pasien IN ('mahasiswa','staf'))
);

CREATE TABLE obat (
    id_obat bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kode_obat varchar(20) NOT NULL UNIQUE,
    nama_obat varchar(150) NOT NULL,
    stok integer NOT NULL DEFAULT 0
        CHECK (stok >= 0),
    satuan varchar(20) NOT NULL
);