# -- Diminta: dependency koneksi, endpoint POST /rentals, dan translasi galat basis data ke HTTP.
# -- Dipilih: psycopg_pool.ConnectionPool + FastAPI Depends, Pydantic buat validasi input.
# -- Alternatif: bikin koneksi baru tiap request; tidak dipilih karena boros dan lambat di beban tinggi.

from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, Field
from psycopg_pool import ConnectionPool
import psycopg

DSN = "postgresql://msbd:msbd2026@localhost:5432/latihan"

pool = ConnectionPool(DSN, min_size=1, max_size=5, open=True)
app = FastAPI()


def get_conn():
    with pool.connection() as conn:
        yield conn


class RentalRequest(BaseModel):
    customer_id: int
    inventory_id: int
    staff_id: int
    amount: float = Field(gt=0)


@app.post("/rentals", status_code=201)
def create_rental(payload: RentalRequest, conn=Depends(get_conn)):
    try:
        with conn.cursor() as cur:
            cur.execute(
                "CALL lab5.process_rental(%s, %s, %s, %s)",
                (payload.customer_id, payload.inventory_id, payload.staff_id, payload.amount),
            )
            cur.execute(
                "SELECT rental_id FROM lab5.rental_tx ORDER BY rental_id DESC LIMIT 1"
            )
            rental_id = cur.fetchone()[0]
        conn.commit()
        return {"rental_id": rental_id}

    except psycopg.errors.ForeignKeyViolation:
        conn.rollback()
        raise HTTPException(status_code=409, detail="Referensi data tidak valid (inventory/customer/staff tidak ditemukan)")

    except psycopg.errors.CheckViolation:
        conn.rollback()
        raise HTTPException(status_code=422, detail="Nilai amount tidak valid")