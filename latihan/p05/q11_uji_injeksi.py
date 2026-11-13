def q11_sql_injection():
    print("\n--- Q11: Uji Injeksi SQL ---")
    payload = "Smith' OR '1'='1"

    unsafe_query = (
        f"SELECT customer_id, first_name, last_name "
        f"FROM public.customer WHERE last_name = '{payload}'"
    )
    print(f"Query tidak aman (f-string): {unsafe_query}")
    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute(unsafe_query)
            unsafe_rows = cur.fetchall()
    print(
        f"Hasil versi TIDAK AMAN: {len(unsafe_rows)} baris "
        "(klausa WHERE menjadi selalu TRUE -> membocorkan SELURUH tabel customer)"
    )

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT customer_id, first_name, last_name "
                "FROM public.customer WHERE last_name = %s",
                (payload,),
            )
            safe_rows = cur.fetchall()
    print(
        f"Hasil versi AMAN (parameter binding): {len(safe_rows)} baris "
        "(payload diperlakukan sebagai satu string literal utuh, bukan sebagai kode SQL)"
    )
    return unsafe_rows, safe_rows
