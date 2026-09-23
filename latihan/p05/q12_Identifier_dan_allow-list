def q12_identifier_allowlist():
    print("\n--- Q12: Identifier & Allow-list ---")

    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT customer_id, first_name FROM public.customer "
                    "ORDER BY %s LIMIT 5",
                    ("first_name",),
                )
                cur.fetchall()
                print("Berhasil (tidak seharusnya, ORDER BY tidak benar-benar bekerja)")
    except errors.IndeterminateDatatype as e:
        # SQLSTATE 42P18 — bukan "galat sintaks" murni seperti dugaan soal,
        # melainkan galat tipe data karena identifier tidak bisa di-bind lewat parameter.
        print(f"GALAT TERTANGKAP (42P18 indeterminate datatype): {e}")
    except psycopg.Error as e:
        print(f"GALAT TERTANGKAP ({e.__class__.__name__}, sqlstate={e.sqlstate}): {e}")

    ALLOWED_ORDER_COLUMNS = {"customer_id", "first_name", "last_name"}
    kolom_diminta = "first_name"

    if kolom_diminta not in ALLOWED_ORDER_COLUMNS:
        raise ValueError(f"Kolom '{kolom_diminta}' tidak diizinkan untuk ORDER BY")

    query = sql.SQL(
        "SELECT customer_id, first_name FROM public.customer ORDER BY {kolom} LIMIT 5"
    ).format(kolom=sql.Identifier(kolom_diminta))

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute(query)
            rows = cur.fetchall()
            print(f"Query aman: {query.as_string(conn)}")
            for row in rows:
                print(row)
    return rows
