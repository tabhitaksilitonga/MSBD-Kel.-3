-- Diminta: Buat tabel permintaan_hapus dengan tenggat 72 jam, tanpa GENERATED.
-- Dipilih: DEFAULT now() + interval '72 hours' karena sesuai dengan fungsi waktu saat insert.
-- Alternatif: GENERATED ALWAYS AS (diterima_pada + interval), tidak dipilih karena ditolak PostgreSQL 17 akibat ekspresi generasinya tidak immutable (bisa berubah tergantung timezone/waktu).

CREATE TABLE lab11.permintaan_hapus (
    id SERIAL PRIMARY KEY,
    pelanggan_id INT NOT NULL,
    waktu_minta TIMESTAMPTZ DEFAULT now(),
    tenggat TIMESTAMPTZ NOT NULL DEFAULT now() + interval '72 hours',
    alasan TEXT
);