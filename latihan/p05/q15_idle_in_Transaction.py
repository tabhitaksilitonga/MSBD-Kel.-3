def q15_idle_in_transaction(durasi_detik: int = 30):
    print("\n--- Q15: Idle in Transaction ---")
    print(f"Membuka transaksi dan menahannya selama {durasi_detik} detik...")
    print("SELAGI MENUNGGU, dari terminal/sesi psql LAIN jalankan:")
    print(
        "  SELECT pid, state, xact_start, query FROM pg_stat_activity "
        "WHERE state LIKE 'idle in%';"
    )
    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT count(*) FROM lab5.rental_tx")
            cur.fetchone()
            time.sleep(durasi_detik)
    print("Transaksi selesai (commit otomatis saat keluar blok `with`).")
