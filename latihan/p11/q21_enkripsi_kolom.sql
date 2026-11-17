
-- Diminta: mengenkripsi kolom rekening untuk 1000 baris pelanggan.
-- Dipilih: pgp_sym_encrypt() dengan kunci simetris per session.
-- Alternatif: hashing tidak dipilih karena rekening harus dapat didekripsi kembali.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

SET app.kunci_kolom = 'kunci-lab11-jangan-dipakai-di-produksi';

ALTER TABLE lab11.pelanggan
ADD COLUMN rekening_enc BYTEA;

UPDATE lab11.pelanggan
SET rekening_enc = pgp_sym_encrypt(
    rekening,
    current_setting('app.kunci_kolom')
)
WHERE id <= 1000;

-- Menguji dekripsi satu rekening
SELECT
    id,
    rekening,
    pgp_sym_decrypt(
        rekening_enc,
        current_setting('app.kunci_kolom')
    ) AS rekening_dekripsi
FROM lab11.pelanggan
WHERE id = 3;

-- Membuktikan enkripsi menghasilkan ciphertext berbeda
SELECT
    pgp_sym_encrypt('1234567890', 'k') =
    pgp_sym_encrypt('1234567890', 'k') AS hasil_sama;
