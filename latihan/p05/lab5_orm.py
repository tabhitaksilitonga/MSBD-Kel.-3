# -- Diminta: memetakan Customer dan Rental, membuktikan N+1, memperbaikinya, dan membandingkan ORM vs SQL mentah.
# -- Dipilih: SQLAlchemy 2.0 declarative style (Mapped/mapped_column) karena type-hinted dan direkomendasikan.
# -- Alternatif: session.query() gaya lama; tidak dipilih karena API 2.0 lebih eksplisit soal loading strategy.

import time
from typing import List
from datetime import datetime
import enum
from sqlalchemy import (
    String, Integer, BigInteger, DateTime, ForeignKey, Enum,
    create_engine, event, select, func, text
)
from sqlalchemy.orm import (
    DeclarativeBase, Mapped, mapped_column, relationship, Session,
    selectinload, joinedload
)

DSN = "postgresql+psycopg://msbd:msbd2026@localhost:5432/pagila"   
engine = create_engine(DSN, echo=True)


class Base(DeclarativeBase): pass


class RentalStatus(enum.Enum):
    ACTIVE = 'ACTIVE'; RETURNED = 'RETURNED'; CANCELLED = 'CANCELLED'

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

class Film(Base):
    __tablename__ = 'film'
    __table_args__ = {'schema': 'public'}

    film_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    title: Mapped[str] = mapped_column(String)


class Inventory(Base):
    __tablename__ = 'inventory'
    __table_args__ = {'schema': 'public'}

    inventory_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    film_id: Mapped[int] = mapped_column(Integer, ForeignKey('public.film.film_id'))


class PublicRental(Base):
    __tablename__ = 'rental'
    __table_args__ = {'schema': 'public'}

    rental_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    inventory_id: Mapped[int] = mapped_column(Integer, ForeignKey('public.inventory.inventory_id'))

statement_count = 0


@event.listens_for(engine, "before_cursor_execute")
def _hitung_statement(conn, cursor, statement, parameters, context, executemany):
    global statement_count
    statement_count += 1


def q17_buktikan_n_plus_1():
    global statement_count
    statement_count = 0
    print("\n--- Q17: N+1 Problem ---")
    with Session(engine) as session:
        customers = session.query(Customer).limit(10).all()
        for c in customers:
            _ = len(c.rentals)
    print(f"--- Selesai. Total statement: {statement_count} (target: 11) ---")


def q18_selectinload():
    global statement_count
    statement_count = 0
    print("\n--- Q18: selectinload ---")
    with Session(engine) as session:
        rows = session.scalars(
            select(Customer).options(selectinload(Customer.rentals)).limit(10)
        ).all()
        for c in rows:
            _ = len(c.rentals)
    print(f"--- Selesai. Total statement: {statement_count} (target: 2) ---")


def q19_joinedload():
    global statement_count
    statement_count = 0
    print("\n--- Q19: joinedload ---")
    with Session(engine) as session:
        rows = session.scalars(
            select(Customer).options(joinedload(Customer.rentals)).limit(10)
        ).unique().all() 
        for c in rows:
            _ = len(c.rentals)
    print(f"--- Selesai. Total statement: {statement_count} (target: 1) ---")


def q20_orm_vs_raw_sql():
    print("\n--- Q20: ORM vs SQL mentah (5 film tersewa terbanyak) ---")

    # -- versi ORM --
    with Session(engine) as session:
        mulai = time.perf_counter()
        hasil_orm = session.execute(
            select(Film.title, func.count(PublicRental.rental_id).label("jumlah"))
            .join(Inventory, Inventory.film_id == Film.film_id)
            .join(PublicRental, PublicRental.inventory_id == Inventory.inventory_id)
            .group_by(Film.film_id, Film.title)
            .order_by(func.count(PublicRental.rental_id).desc())
            .limit(5)
        ).all()
        waktu_orm = time.perf_counter() - mulai

    # -- versi SQL mentah --
    with Session(engine) as session:
        mulai = time.perf_counter()
        hasil_raw = session.execute(text("""
            SELECT f.title, count(r.rental_id) AS jumlah
            FROM public.film f
            JOIN public.inventory i ON i.film_id = f.film_id
            JOIN public.rental r ON r.inventory_id = i.inventory_id
            GROUP BY f.film_id, f.title
            ORDER BY jumlah DESC
            LIMIT 5
        """)).all()
        waktu_raw = time.perf_counter() - mulai

    print(f"ORM  : {hasil_orm}  -> {waktu_orm*1000:.2f} ms")
    print(f"Raw  : {hasil_raw}  -> {waktu_raw*1000:.2f} ms")


if __name__ == "__main__":
    q17_buktikan_n_plus_1()
    q18_selectinload()
    q19_joinedload()
    q20_orm_vs_raw_sql()