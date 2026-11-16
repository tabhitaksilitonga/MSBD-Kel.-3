import sys
import psycopg2

if len(sys.argv) < 2:
    print("Gunakan: python rentan.py <kata_kunci>")
    sys.exit(1)

kata = sys.argv[1]

try:
    # Koneksi default ke database (Bisa diubah Kersa nanti ke app_laporan)
    conn = psycopg2.connect(
        host="lab11-db",
        database="msbd",
        user="postgres",
        password="password"
    )
    cur = conn.cursor()

    # RANGKAIAN STRING RENTAN
    query = f"SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%{kata}' LIMIT 100;"
    
    print("Teks SQL yang tercetak:")
    print(query)
    print("-" * 30)
    
    cur.execute(query)
    rows = cur.fetchall()
    
    print(f"Hasil: {len(rows)} baris.")
    for r in rows[:5]:
        print(r)

except Exception as e:
    print(f"Galat: {e}")
finally:
    if 'conn' in locals() and conn:
        conn.close()