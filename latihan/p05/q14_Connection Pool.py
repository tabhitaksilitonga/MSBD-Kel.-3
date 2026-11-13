def q14_connection_pool():
    print("\n--- Q14: Connection Pool ---")
    with ConnectionPool(DSN, min_size=2, max_size=2) as pool:
        pool.wait()
        for i in range(1, 6):
            with pool.connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT count(*) FROM lab5.rental_tx")
                    total = cur.fetchone()[0]
                    print(f"Query #{i}: total rental_tx = {total}")
        print(f"Statistik pool: {pool.get_stats()}")
