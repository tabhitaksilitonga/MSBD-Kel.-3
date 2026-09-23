import psycopg
from psycopg import errors

# gantiin databaseny w
DSN = "postgresql://postgres:postgres@localhost:5432/sakila" 

def test_q4():
    print("--- Menguji Q4: COMMIT dalam Procedure ---")
    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute("CALL lab5.process_rental_commit(1, 1, 1, 4.99)")
                print("Berhasil (Seharusnya tidak muncul)")
    except errors.InvalidTransactionTermination as e:
        print(f"ERROR TERTANGKAP: {e}")
    except Exception as e:
        print(f"Error lain: {e}")

if __name__ == "__main__":
    test_q4()