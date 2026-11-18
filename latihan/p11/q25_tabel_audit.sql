-- Diminta: Buat tabel jejak_audit dan trigger rekam_audit dengan session_user. Jangan beri hak INSERT ke aplikasi.
-- Dipilih: Menggunakan session_user agar peran login asli (manusia/aplikasi) yang terekam.
-- Alternatif: current_user tidak dipilih karena di dalam trigger SECURITY DEFINER, ia akan menghasilkan pemilik fungsi, sehingga pelaku asli tidak terlacak.

CREATE TABLE lab11.jejak_audit (
    id SERIAL PRIMARY KEY,
    waktu TIMESTAMPTZ DEFAULT now(),
    pelaku VARCHAR(50) DEFAULT session_user,
    aksi VARCHAR(10),
    tabel VARCHAR(50),
    kunci INT,
    nilai_lama JSONB
);

-- Cabut akses dari pengguna aplikasi, sehingga tidak bisa memalsukan log
REVOKE ALL ON lab11.jejak_audit FROM app_read, app_write, app_laporan, app_portal;

CREATE OR REPLACE FUNCTION lab11.fn_rekam_audit()
RETURNS TRIGGER 
SECURITY DEFINER -- Fungsi berjalan dengan hak skema_owner
AS $$
BEGIN
    INSERT INTO lab11.jejak_audit (aksi, tabel, kunci, nilai_lama)
    VALUES (TG_OP, TG_TABLE_NAME, OLD.id, row_to_json(OLD));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rekam_audit
AFTER UPDATE OR DELETE ON lab11.pelanggan
FOR EACH ROW EXECUTE FUNCTION lab11.fn_rekam_audit();