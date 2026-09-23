# Laporan Latihan Kelompok Pertemuan 5

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |
| :--- | :--- | :--- | :--- |
| Tabhita Kristy SIlitonga | 251402023 | Project Manager, Setup Q00, Verifikasi lingkungan, dan Finalisasi laporan & readme | 277c52c |
| Jevine Jeje Zakarias Simanjuntak | 251402085 | Q01–Q05: PL/pgSQL Function, Stored Procedure & Transaction Control, dan Reflektif A | d751abb |
| Fadila Lisma Sari | 251402117 | Q06–Q09: PostgreSQL Types (Domain, Enum, Array, & JSONB), dan Reflektif B & D | f774666 |
| Qairsya Naurel ein Yaliki | 251402120 | Q10–Q15: psycopg Driver, Sanitasi Query, Connection Pool & Idle Transaction, dan Reflektif C | 9bb50e3 |
| Reynald Alvaro Pasaribu | 251402147 | Q16–Q24: SQLAlchemy ORM (lab5_orm.py) & FastAPI REST API (lab5_api.py) | be529a0 |

---

## Q1-Q24
Perintah, Keluaran, dan Alasan keputusan.

### Q1 - total_dibayar

**Perintah:**
```sql
CREATE OR REPLACE FUNCTION lab5.total_dibayar(p_rental_id bigint)
RETURNS numeric LANGUAGE sql STABLE AS $$
    SELECT coalesce(sum(amount), 0) 
    FROM lab5.payment_tx 
    WHERE rental_id = p_rental_id;
$$;

SELECT lab5.total_dibayar(1);
```
**Keluaran:**
CREATE FUNCTION
 total_dibayar 
---------------
             0
(1 row)

**Alasan keputusan:**
lab5.total_dibayar pakai coalesce(sum(amount), 0) untuk menjumlahkan seluruh pembayaran di rental_id tertentu. Fungsi COALESCE memastikan kalau belum ada pembayaran (NULL), nilai yang dikembalikan tetap 0, bukan NULL.

### Q2 - process_rental

**Perintah:**
```sql
CREATE OR REPLACE PROCEDURE lab5.process_rental(
    p_customer_id integer,
    p_inventory_id integer,
    p_staff_id integer,
    p_amount numeric
) LANGUAGE plpgsql AS $$
DECLARE
    v_rental_id bigint;
BEGIN
    INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id, status)
    VALUES (p_customer_id, p_inventory_id, p_staff_id, 'ACTIVE')
    RETURNING rental_id INTO v_rental_id;

    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);
END;
$$;

CALL lab5.process_rental(1, 1, 1, 4.99);
SELECT count(*) FROM lab5.rental_tx;
```
**Keluaran:**
CREATE PROCEDURE
CALL
 count 
-------
     1
(1 row)

**Alasan keputusan:**
prosedur process_rental berhasil mengeksekusi dua perintah INSERT (ke rental_tx dan payment_tx) dalam satu blok transaksi. Pemanggilan dengan parameter yang sah (nominal positif dan ID referensi valid) berhasil menambahkan satu baris data di tabel rental_tx.

### Q3 - buktikan_rollback

**Perintah:**
```sql
SELECT count(*) AS sebelum FROM lab5.rental_tx;

CALL lab5.process_rental(1, 1, 1, -4.99);

SELECT count(*) AS sesudah FROM lab5.rental_tx;
```
**Keluaran:**
sebelum 
---------
       1
(1 row)

psql:/proc/self/fd/0:3: ERROR:  value for domain lab5.positive_amount violates check constraint "positive_amount_check"
CONTEXT:  SQL statement "INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount)"
PL/pgSQL function lab5.process_rental(integer,integer,integer,numeric) line 9 at SQL statement

 sesudah 
---------
       1
(1 row)

**Alasan keputusan:**
dipanggil dengan nominal negatif (-4.99) yang melanggar domain positive_amount. Karena PL/pgSQL mengeksekusi prosedur dalam satu blok transaksi, kegagalan pada INSERT kedua memicu ROLLBACK otomatis oleh server PostgreSQL. Akibatnya, INSERT pertama (ke rental_tx) yg udah berjalan ikut dibatalkan, sehingga jumlah data sebelum dan sesudah tetap sama.

### Q4 - commit_dalam_procedure

**Perintah:**
```sql
CREATE OR REPLACE PROCEDURE lab5.process_rental_commit(
    p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric
) LANGUAGE plpgsql AS $$
DECLARE v_rental_id bigint;
BEGIN
    INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)
    VALUES (p_customer_id, p_inventory_id, p_staff_id)
    RETURNING rental_id INTO v_rental_id;

    COMMIT; 

    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);
END;
$$;
```
**Keluaran:**
Traceback (most recent call last):
  File "<string>", line 7, in <module>
    cur.execute('CALL lab5.process_rental_with_commit(%s, %s, %s, %s);', (1, 1, 1, 4.99))
    ~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "D:\msbd-2026\.venv\Lib\site-packages\psycopg\cursor.py", line 732, in execute
    raise ex.with_traceback(None)
psycopg.errors.InvalidTransactionTermination: cannot commit while a subtransaction is active
CONTEXT:  PL/pgSQL function lab5.process_rental_with_commit(integer,integer,integer,numeric) line 11 at COMMIT

**Alasan keputusan:**
psycopg nya secara default mengelola transaksi di sisi klien (mengirimkan BEGIN implisit). PostgreSQL melarang prosedur untuk melakukan COMMIT atau ROLLBACK eksplisit kalau prosedur tersebut dipanggil dari dalam blok transaksi yang sedang aktif dan dikelola oleh klien.

### Q5 - exception_fk

**Perintah:**
```sql
CREATE OR REPLACE PROCEDURE lab5.process_rental_safe(
    p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric
) LANGUAGE plpgsql AS $$
DECLARE v_rental_id bigint;
BEGIN
    INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)
    VALUES (p_customer_id, p_inventory_id, p_staff_id)
    RETURNING rental_id INTO v_rental_id;

    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Gagal: ID Customer, Inventory, atau Staff tidak valid/tidak ditemukan.';
END;
$$;
```
**Keluaran:**
ERROR:  Gagal: ID Customer, Inventory, atau Staff tidak valid/tidak ditemukan.
CONTEXT:  PL/pgSQL function lab5.process_rental_safe(integer,integer,integer,numeric) line 12 at RAISE

**Alasan keputusan:**
Blok EXCEPTION WHEN foreign_key_violation nangkap error mentah dari database dan menggantinya dengan pesan kustom.
Informasi yang hilang: Nama constraint spesifik, nama tabel, dan nilai key yang gagal.

### Q6 — Domain positive_amount

**Perintah:**
```sql
INSERT INTO lab5.payment_tx (rental_id, amount)
VALUES (1, 0);

INSERT INTO lab5.payment_tx (rental_id, amount)
VALUES (1, -10);
```
**Keluaran:**
ERROR: 23514: value for domain lab5.positive_amount violates check constraint "positive_amount_check"

ERROR: 23514: value for domain lab5.positive_amount violates check constraint "positive_amount_check"

**Alasan keputusan:**
Domain lab5.positive_amount digunakan untuk memastikan nilai pembayaran
harus lebih besar dari 0. Nilai 0 dan negatif ditolak oleh constraint
VALUE > 0. SQLSTATE 23514 menunjukkan pelanggaran check constraint.

### Q7 — ENUM rental_status

**Perintah:**
```sql
UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;
```
**Keluaran:**
ERROR: 22P02: invalid input value for enum lab5.rental_status: "EXPIRED"

ALTER TYPE lab5.rental_status
ADD VALUE 'EXPIRED';
**Keluaran:**
ALTER TYPE

**Percobaan ulang:**
```sql
UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;
```
**Keluaran:**
UPDATE 1

**Verifikasi:**
```sql
SELECT rental_id, status
FROM lab5.rental_tx
WHERE rental_id = 1;
```
**Keluaran:**
rental_id | status
----------+--------
1         | EXPIRED

**Alasan keputusan:**
ENUM digunakan untuk membatasi nilai status rental. Nilai EXPIRED
awalnya tidak diperbolehkan, tetapi setelah ditambahkan menggunakan
ALTER TYPE, nilai tersebut dapat digunakan.

### Q8 — Array Tags

**Perintah:**
```sql
UPDATE lab5.rental_tx
SET tags = ARRAY['promo','akhir-pekan','anggota']
WHERE rental_id = 1;
```
**Keluaran:**
UPDATE 1

**Perintah:**
```sql
SELECT rental_id, tags
FROM lab5.rental_tx
WHERE 'promo' = ANY(tags);
```
**Keluaran:**
rental_id | tags
----------+-----------------------------
1         | {promo,akhir-pekan,anggota}

**Alasan keputusan:**
Array digunakan untuk menyimpan beberapa tag dalam satu kolom.
Operator ANY digunakan untuk mencari baris yang memiliki tag tertentu,
yaitu 'promo'.

### Q9 — JSONB Metadata

**Perintah:**
```sql
UPDATE lab5.rental_tx
SET metadata = '{"channel":"web","device":"android"}'::jsonb
WHERE rental_id = 1;
```
**Keluaran:**
UPDATE 1

**Perintah:**
```sql
SELECT rental_id, metadata ->> 'channel' AS kanal
FROM lab5.rental_tx
WHERE rental_id = 1;
```
**Keluaran:**
rental_id | kanal
----------+-------
1         | web

**Alasan keputusan:**
JSONB digunakan untuk menyimpan metadata yang memiliki struktur
key-value. Operator ->> digunakan untuk mengambil nilai channel
sebagai teks dari data JSONB.

### Q16 — Model Deklaratif

**Perintah:**
```python
class Customer(Base):
    __tablename__ = 'customer'
    __table_args__ = {'schema': 'public'}

    customer_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    first_name: Mapped[str] = mapped_column(String)
    last_name: Mapped[str] = mapped_column(String)
    rentals: Mapped[List["Rental"]] = relationship(back_populates="customer", lazy="select")


class Rental(Base):
    __tablename__ = 'rental_tx'
    __table_args__ = {'schema': 'lab5'}

    rental_id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    customer_id: Mapped[int] = mapped_column(Integer, ForeignKey('public.customer.customer_id'))
    inventory_id: Mapped[int] = mapped_column(Integer)
    staff_id: Mapped[int] = mapped_column(Integer)
    status: Mapped[RentalStatus] = mapped_column(Enum(RentalStatus, name='rental_status', schema='lab5'))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    customer: Mapped["Customer"] = relationship(back_populates="rentals")
```
**Keluaran:**
Tidak ada output runtime langsung; model ini dipakai sebagai definisi
tabel untuk seluruh query di Q17-Q20.

**Alasan keputusan:**
Gaya deklaratif SQLAlchemy 2.0 (Mapped/mapped_column) dipilih karena
type-hinted dan direkomendasikan untuk versi 2.0. Parameter
name='rental_status' pada Enum wajib ditulis eksplisit, karena tanpa
itu SQLAlchemy menebak nama tipe dari nama class Python (RentalStatus),
padahal tipe ENUM yang sebenarnya ada di database bernama rental_status
(huruf kecil, sesuai q00_setup.sql) sehingga tanpa alias ini query akan
gagal dengan error "type does not exist".

### Q17 — Bukti N+1

**Perintah:**
```python
def q17_buktikan_n_plus_1():
    with Session(engine) as session:
        customers = session.query(Customer).limit(10).all()
        for c in customers:
            _ = len(c.rentals)
```
**Keluaran:**
--- Q17: N+1 Problem ---
2026-09-23 18:30:02,701 INFO sqlalchemy.engine.Engine select pg_catalog.version()
2026-09-23 18:30:02,701 INFO sqlalchemy.engine.Engine [raw sql] {}
2026-09-23 18:30:02,703 INFO sqlalchemy.engine.Engine select current_schema()
2026-09-23 18:30:02,704 INFO sqlalchemy.engine.Engine [raw sql] {}
2026-09-23 18:30:02,705 INFO sqlalchemy.engine.Engine show standard_conforming_strings
2026-09-23 18:30:02,705 INFO sqlalchemy.engine.Engine [raw sql] {}
2026-09-23 18:30:02,709 INFO sqlalchemy.engine.Engine BEGIN (implicit)
2026-09-23 18:30:02,711 INFO sqlalchemy.engine.Engine SELECT public.customer.customer_id AS public_customer_customer_id, public.customer.first_name AS public_customer_first_name, public.customer.last_name AS public_customer_last_name 
FROM public.customer 
 LIMIT %(param_1)s::INTEGER
2026-09-23 18:30:02,712 INFO sqlalchemy.engine.Engine [generated in 0.00040s] {'param_1': 10}
2026-09-23 18:30:02,720 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,721 INFO sqlalchemy.engine.Engine [generated in 0.00125s] {'param_1': 1}
2026-09-23 18:30:02,742 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,743 INFO sqlalchemy.engine.Engine [cached since 0.02315s ago] {'param_1': 2}
2026-09-23 18:30:02,745 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,745 INFO sqlalchemy.engine.Engine [cached since 0.02566s ago] {'param_1': 3}
2026-09-23 18:30:02,747 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,747 INFO sqlalchemy.engine.Engine [cached since 0.02756s ago] {'param_1': 4}
2026-09-23 18:30:02,749 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,749 INFO sqlalchemy.engine.Engine [cached since 0.02899s ago] {'param_1': 5}
2026-09-23 18:30:02,750 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,750 INFO sqlalchemy.engine.Engine [cached since 0.03032s ago] {'param_1': 6}
2026-09-23 18:30:02,752 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,752 INFO sqlalchemy.engine.Engine [cached since 0.03198s ago] {'param_1': 7}
2026-09-23 18:30:02,753 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,753 INFO sqlalchemy.engine.Engine [cached since 0.03321s ago] {'param_1': 8}
2026-09-23 18:30:02,754 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,754 INFO sqlalchemy.engine.Engine [cached since 0.03435s ago] {'param_1': 9}
2026-09-23 18:30:02,755 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE %(param_1)s::INTEGER = lab5.rental_tx.customer_id
2026-09-23 18:30:02,757 INFO sqlalchemy.engine.Engine [cached since 0.03684s ago] {'param_1': 10}
2026-09-23 18:30:02,758 INFO sqlalchemy.engine.Engine ROLLBACK
--- Selesai. Total statement: 11 (target: 11) ---

**Alasan keputusan:**
Mengakses c.rentals di dalam loop memicu lazy load: setiap customer
menjalankan SELECT terpisah ke rental_tx saat atributnya diakses.
Untuk 10 customer, totalnya 1 SELECT (ambil customer) + 10 SELECT
(satu per customer) = 11 statement — inilah masalah N+1 yang diminta
dibuktikan.

### Q18 — selectinload

**Perintah:**
```python
def q18_selectinload():
    with Session(engine) as session:
        rows = session.scalars(
            select(Customer).options(selectinload(Customer.rentals)).limit(10)
        ).all()
        for c in rows:
            _ = len(c.rentals)
```
**Keluaran:**
--- Q18: selectinload ---
2026-09-23 18:30:02,760 INFO sqlalchemy.engine.Engine BEGIN (implicit)
2026-09-23 18:30:02,761 INFO sqlalchemy.engine.Engine SELECT public.customer.customer_id, public.customer.first_name, public.customer.last_name 
FROM public.customer 
 LIMIT %(param_1)s::INTEGER
2026-09-23 18:30:02,761 INFO sqlalchemy.engine.Engine [generated in 0.00015s] {'param_1': 10}
2026-09-23 18:30:02,766 INFO sqlalchemy.engine.Engine SELECT lab5.rental_tx.customer_id AS lab5_rental_tx_customer_id, lab5.rental_tx.rental_id AS lab5_rental_tx_rental_id, lab5.rental_tx.inventory_id AS lab5_rental_tx_inventory_id, lab5.rental_tx.staff_id AS lab5_rental_tx_staff_id, lab5.rental_tx.status AS lab5_rental_tx_status, lab5.rental_tx.created_at AS lab5_rental_tx_created_at 
FROM lab5.rental_tx 
WHERE lab5.rental_tx.customer_id IN (%(primary_keys_1)s::INTEGER, %(primary_keys_2)s::INTEGER, %(primary_keys_3)s::INTEGER, %(primary_keys_4)s::INTEGER, %(primary_keys_5)s::INTEGER, %(primary_keys_6)s::INTEGER, %(primary_keys_7)s::INTEGER, %(primary_keys_8)s::INTEGER, %(primary_keys_9)s::INTEGER, %(primary_keys_10)s::INTEGER)
2026-09-23 18:30:02,766 INFO sqlalchemy.engine.Engine [generated in 0.00031s] {'primary_keys_1': 1, 'primary_keys_2': 2, 'primary_keys_3': 3, 'primary_keys_4': 4, 'primary_keys_5': 5, 'primary_keys_6': 6, 'primary_keys_7': 7, 'primary_keys_8': 8, 'primary_keys_9': 9, 'primary_keys_10': 10}
2026-09-23 18:30:02,770 INFO sqlalchemy.engine.Engine ROLLBACK
--- Selesai. Total statement: 2 (target: 2) ---

**Alasan keputusan:**
selectinload memuat relasi lewat query kedua yang memakai
WHERE customer_id IN (...) untuk seluruh customer sekaligus, sehingga
jumlah statement tidak lagi bergantung pada jumlah baris (10 customer
tetap 2 query: 1 untuk customer, 1 untuk semua rental terkait).

### Q19 — joinedload

**Perintah:**
```python
def q19_joinedload():
    with Session(engine) as session:
        rows = session.scalars(
            select(Customer).options(joinedload(Customer.rentals)).limit(10)
        ).unique().all()
        for c in rows:
            _ = len(c.rentals)
```
**Keluaran:**
--- Q19: joinedload ---
2026-09-23 18:30:02,773 INFO sqlalchemy.engine.Engine BEGIN (implicit)
2026-09-23 18:30:02,776 INFO sqlalchemy.engine.Engine SELECT anon_1.customer_id, anon_1.first_name, anon_1.last_name, rental_tx_1.rental_id, rental_tx_1.customer_id AS customer_id_1, rental_tx_1.inventory_id, rental_tx_1.staff_id, rental_tx_1.status, rental_tx_1.created_at 
FROM (SELECT public.customer.customer_id AS customer_id, public.customer.first_name AS first_name, public.customer.last_name AS last_name 
FROM public.customer 
 LIMIT %(param_1)s::INTEGER) AS anon_1 LEFT OUTER JOIN lab5.rental_tx AS rental_tx_1 ON anon_1.customer_id = rental_tx_1.customer_id
2026-09-23 18:30:02,777 INFO sqlalchemy.engine.Engine [generated in 0.00140s] {'param_1': 10}
2026-09-23 18:30:02,781 INFO sqlalchemy.engine.Engine ROLLBACK
--- Selesai. Total statement: 1 (target: 1) ---

**Alasan keputusan:**
joinedload menggabungkan customer dan rental dalam satu LEFT OUTER JOIN,
sehingga hanya perlu 1 statement. Karena JOIN menghasilkan baris
customer yang terduplikasi per rental, .unique() wajib dipanggil di
sisi Python untuk deduplikasi — tanpa ini SQLAlchemy 2.0 melempar
InvalidRequestError. Dibanding Q18, bentuk SQL-nya adalah satu query
gabungan (JOIN), bukan dua query terpisah.

### Q20 — ORM vs SQL Mentah

**Perintah:**
```python
# versi ORM
select(Film.title, func.count(PublicRental.rental_id).label("jumlah"))
    .join(Inventory, Inventory.film_id == Film.film_id)
    .join(PublicRental, PublicRental.inventory_id == Inventory.inventory_id)
    .group_by(Film.film_id, Film.title)
    .order_by(func.count(PublicRental.rental_id).desc())
    .limit(5)

# versi SQL mentah
text("""
    SELECT f.title, count(r.rental_id) AS jumlah
    FROM public.film f
    JOIN public.inventory i ON i.film_id = f.film_id
    JOIN public.rental r ON r.inventory_id = i.inventory_id
    GROUP BY f.film_id, f.title
    ORDER BY jumlah DESC
    LIMIT 5
""")
```
**Keluaran:**
--- Q20: ORM vs SQL mentah (5 film tersewa terbanyak) ---
2026-09-23 18:30:02,786 INFO sqlalchemy.engine.Engine BEGIN (implicit)
2026-09-23 18:30:02,788 INFO sqlalchemy.engine.Engine SELECT public.film.title, count(public.rental.rental_id) AS jumlah 
FROM public.film JOIN public.inventory ON public.inventory.film_id = public.film.film_id JOIN public.rental ON public.rental.inventory_id = public.inventory.inventory_id GROUP BY public.film.film_id, public.film.title ORDER BY count(public.rental.rental_id) DESC 
 LIMIT %(param_1)s::INTEGER
2026-09-23 18:30:02,788 INFO sqlalchemy.engine.Engine [generated in 0.00021s] {'param_1': 5}
2026-09-23 18:30:02,811 INFO sqlalchemy.engine.Engine ROLLBACK
2026-09-23 18:30:02,812 INFO sqlalchemy.engine.Engine BEGIN (implicit)
2026-09-23 18:30:02,812 INFO sqlalchemy.engine.Engine 
            SELECT f.title, count(r.rental_id) AS jumlah
            FROM public.film f
            JOIN public.inventory i ON i.film_id = f.film_id
            JOIN public.rental r ON r.inventory_id = i.inventory_id
            GROUP BY f.film_id, f.title
            ORDER BY jumlah DESC
            LIMIT 5
        
2026-09-23 18:30:02,813 INFO sqlalchemy.engine.Engine [generated in 0.00019s] {}
2026-09-23 18:30:02,818 INFO sqlalchemy.engine.Engine ROLLBACK
ORM  : [('BUCKET BROTHERHOOD', 34), ('ROCKETEER MOTHER', 33), ('GRIT CLOCKWORK', 32), ('RIDGEMONT SUBMARINE', 32), ('FORWARD TEMPLE', 32)]  -> 25.71 ms
Raw  : [('BUCKET BROTHERHOOD', 34), ('ROCKETEER MOTHER', 33), ('GRIT CLOCKWORK', 32), ('RIDGEMONT SUBMARINE', 32), ('FORWARD TEMPLE', 32)]  -> 6.41 ms

**Alasan keputusan:**
Kedua versi diterjemahkan menjadi SQL yang secara struktural identik,
sehingga perbedaan waktu eksekusi terutama berasal dari overhead
sisi Python (hidrasi objek ORM) dibanding tuple mentah, bukan dari
query plan di database.

### Q21 — Dependency Koneksi

**Perintah:**
```python
def get_conn():
    with pool.connection() as conn:
        yield conn
```
**Keluaran:**
Tidak ada output runtime langsung; dependency ini dipanggil otomatis
oleh FastAPI setiap kali endpoint yang menggunakan Depends(get_conn)
dieksekusi.

**Alasan keputusan:**
pool.connection() dipakai sebagai context manager sehingga koneksi
otomatis dikembalikan ke pool walau request gagal di tengah jalan
(exception). yield dipilih, bukan return, karena FastAPI membutuhkan
generator untuk dependency yang punya cleanup setelah response dikirim.

### Q22 — POST /rentals

**Perintah:**
```bash
curl -s -X POST localhost:8000/rentals -H 'content-type: application/json' \
  -d '{"customer_id":1,"inventory_id":1,"staff_id":1,"amount":4.99}'
```
**Keluaran:**
{
  "rental_id": 2
}

**Alasan keputusan:**
status_code=201 dipasang eksplisit di decorator endpoint sesuai
konvensi REST untuk resource baru yang berhasil dibuat.

### Q23 — Nilai Negatif (422)

**Perintah:**
```bash
curl -s -i -X POST localhost:8000/rentals -H 'content-type: application/json' \
  -d '{"customer_id":1,"inventory_id":1,"staff_id":1,"amount":-4.99}'
```
**Keluaran:**
{
  "detail": [
    {
      "type": "greater_than",
      "loc": [
        "body",
        "amount"
      ],
      "msg": "Input should be greater than 0",
      "input": 0,
      "ctx": {
        "gt": 0
      }
    }
  ]
}

**Alasan keputusan:**
Validasi Field(gt=0) di Pydantic menolak nilai sebelum request masuk
ke database, sehingga kegagalan terjadi di lapisan aplikasi (422)
alih-alih di database yang akan menghasilkan 500 bila tidak ditangani.

### Q24 — Inventory Tidak Ada (409)

**Perintah:**
```bash
curl -s -i -X POST localhost:8000/rentals -H 'content-type: application/json' \
  -d '{"customer_id":1,"inventory_id":999999,"staff_id":1,"amount":4.99}'
```
**Keluaran:**
{
  "detail": "Referensi data tidak valid (inventory/customer/staff tidak ditemukan)"
}

**Alasan keputusan:**
ForeignKeyViolation dari Postgres ditangkap dan diterjemahkan menjadi
409 dengan pesan generik, sehingga klien tidak melihat detail SQL
atau struktur tabel yang sebenarnya.

---

## Reflektif A

**Setelah Q3 dan Q4, siapa yang memulai transaksi, siapa yang mengakhirinya, dan bagaimana kelompok membuktikannya dari data?**
> di Q3, transaksi dimulai dan diakhiri oleh Database Engine (PostgreSQL). Server memulai transaksi implisit saat CALL dieksekusi, dan mengakhirinya dengan auto-rollback saat mendeteksi pelanggaran domain. Kelompok membuktikannya dari data dengan melihat hasil SELECT count(*) AS sebelum dan sesudah yang angkanya tetap sama.
> kalau di Q4, transaksi dimulai oleh Klien/Driver (psycopg) secara implisit saat koneksi dibuka, dan seharusnya diakhiri oleh procedure (COMMIT), tapi, Klien/Driver yang mengakhiri transaksi tersebut dengan menolak perintah COMMIT dari procedure. Kelompok membuktikannya dari munculnya pesan error invalid transaction termination di terminal Python dan tidak adanya data baru yang tersimpan di tabel.

---

## Reflektif B

**Pilih tags atau metadata. Apakah sebaiknya tetap di sana atau dipindahkan menjadi tabel? Berikan satu pertanyaan bisnis yang dapat mengubah keputusan tersebut.**
> Saya memilih ags untuk dianalisis. Menurut saya, tags sebaiknya tetap disimpan dalam bentuk array pada kolom `tags` karena satu rental dapat memiliki beberapa tag dan tag tersebut hanya berfungsi sebagai informasi tambahan. Dengan array, beberapa tag dapat disimpan dalam satu baris tanpa membutuhkan tabel tambahan.
> Namun, keputusan tersebut dapat berubah jika kebutuhan bisnis menjadi lebih kompleks. Misalnya, jika bisnis membutuhkan pertanyaan seperti “Berapa banyak rental yang menggunakan setiap tag dan bagaimana penggunaan tag tersebut berubah setiap bulan?”, maka tags lebih tepat dipindahkan ke tabel terpisah agar setiap tag dapat dikelola, dihitung, dan dianalisis dengan lebih mudah.

---

## Reflektif c

**Bandingkan rollback Q3 yang dipicu basis data dan Q13 yang dipicu Python. Apa persamaannya, dan apa satu hal yang hanya dapat dilakukan oleh sisi aplikasi?**
> Persamaannya, keduanya membuktikan sebuah transaksi yang belum di-COMMIT tidak pernah menyisakan perubahan sebagian (partial write). Di Q3, PostgreSQL sendiri yang menolak karena amount melanggar domain positive_amount, jadi seluruh transaksi (termasuk INSERT rental_tx yang sudah berjalan) dibatalkan otomatis oleh server. Di Q13, kegagalannya bukan dari basis data (procedure-nya sukses tanpa galat SQL) — kegagalannya dari logika Python (RuntimeError) sebelum blok with conn sempat commit, sehingga psycopg yang melakukan ROLLBACK otomatis.
> Satu hal yang hanya bisa dilakukan sisi aplikasi: membatalkan transaksi karena alasan yang sama sekali tidak diketahui basis data — misalnya API eksternal gagal, validasi bisnis tambahan, timeout, atau keputusan user membatalkan proses. Basis data tidak tahu apa-apa soal RuntimeError kita; kalau hanya mengandalkan SQL, statement itu tetap valid dan akan ikut ter-commit begitu saja.

## Reflektif D

**Untuk Q20, versi mana yang dipilih jika kode dibaca ulang tim enam bulan lagi? Dukung jawaban dengan angka. Sebutkan pula keadaan ketika joinedload lebih tepat dari selectinload.**
> Versi ORM lebih dipilih untuk dibaca ulang enam bulan lagi ([X] ms vs raw [Y] ms), karena query-nya dibangun dari objek model yang type-safe dan otomatis ikut berubah kalau kolom/tabel di-refactor, tanpa perlu membaca string SQL mentah — selisih waktu [Z] ms dianggap nggak signifikan buat query non-kritis kayak gini. joinedload lebih tepat dipakai untuk relasi one-to-one atau many-to-one dengan hasil kecil, karena cukup satu query JOIN. selectinload lebih cocok buat relasi one-to-many dengan banyak baris anak, karena JOIN pada relasi besar bakal menduplikasi baris induk dan boros transfer data.

## Reflektif E

**Untuk nilai negatif, validasi dipasang di Pydantic dan domain basis data. Jelaskan apa yang hilang jika salah satunya dihapus, untuk kedua arah.**
> Kalau validasi Pydantic dihapus, amount negatif lolos ke database dan baru ditolak oleh domain positive_amount — tanpa penanganan khusus, klien menerima 500 yang generik dan berpotensi membocorkan detail SQL, padahal harusnya 422 yang rapi sebelum menyentuh database. Kalau domain di database yang dihapus, aplikasi kehilangan pertahanan terakhir: validasi Pydantic cuma berlaku untuk request lewat endpoint ini, jadi jalur lain seperti script atau akses langsung ke database bisa nulis nilai negatif tanpa ada yang nolak.

---

## Di Mana Aturan Itu Tinggal
| Aturan | Lapisan | Risiko bila dipindahkan | Bukti |
|---|---|---|---|

---

## Ringkasan N+1
| Q17 | Q18 | Q19 | Penafsiran |
| 11 | 2 | 1 | Pada Q17 terjadi masalah N+1 (lazy loading) di mana 1 query awal mengambil 10 baris customer, lalu diikuti 10 query terpisah untuk mengambil data relasi rental masing-masing customer (total 11 statement). 
Masalah ini dioptimasi pada Q18 menggunakan selectinload yang memisahkan pengambilan relasi ke dalam 1 query tambahan berbasis klausa IN (total 2 statement). 
Pada Q19, joinedload menyatukan kedua entitas menggunakan klausul LEFT OUTER JOIN sehingga seluruh data terambil dalam 1 statement tunggal, membuktikan pemilihan strategi eager loading mampu mengeliminasi latensi round-trip basis data. |

---

## Penggunaan AI dan Verifikasi

Untuk latihan ini, kami menggunakan AI sebagai alat diskusi untuk membantu kami dalam pemahaman materi dan tugasnya, serta membantu proses debugging. Disini AI membantu kami dalam konfigurasi *environment* di sistem operasi windows, seperti aktivasi *virtual environment* python di git bash/terminal dan perbaikan sintaks operator saat instalasi pustaka melalui pip. Kami juga berdiskusi dengan AI ketika mengeksekusi skrip ke dalam kontainer docker serta menganalisis pesan galat yang muncul, khususnya saat memahami alasan driver `psycopg` menolak perintah COMMIT di dalam *procedure* (galat *invalid transaction termination* pada Q04) dan memastikan blok penanganan *foreign key violation* pada Q05 sudah bekerja sesuai skenario. Selain itu, penjelasan AI membantu kami mengonfirmasi pemahaman terkait analisis N+1 pada SQLAlchemy serta alur *connection pool* di FastAPI. Seluruh yang kami dapat dari ai tidak kami copas, kami selalu run ulang setiap kode di terminal secara mandiri, memastikan kesesuaiannya dengan ketentuan di kelas usu, dan memvalidasi langsung luaran yang dihasilkan sebelum dimasukkan ke dalam laporan ini.