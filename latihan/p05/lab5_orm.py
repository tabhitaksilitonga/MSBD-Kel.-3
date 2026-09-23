from typing import List
from datetime import datetime
import enum
from sqlalchemy import String, Integer, BigInteger, Numeric, DateTime, ForeignKey, Enum, create_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship, Session

# GANTI DENGAN DSN (Gunakan postgresql+psycopg untuk SQLAlchemy)
DSN = "postgresql+psycopg://postgres:postgres@localhost:5432/sakila"
engine = create_engine(DSN, echo=True)

class Base(DeclarativeBase): pass

class RentalStatus(enum.Enum):
    ACTIVE = 'ACTIVE'; RETURNED = 'RETURNED'; CANCELLED = 'CANCELLED'

# Model Customer
class Customer(Base):
    __tablename__ = 'customer'
    __table_args__ = {'schema': 'public'}
    
    customer_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    first_name: Mapped[str] = mapped_column(String) # Sesuaikan jika kolom beda
    last_name: Mapped[str] = mapped_column(String)
    rentals: Mapped[List["Rental"]] = relationship(back_populates="customer", lazy="select")

# Model Rental
class Rental(Base):
    __tablename__ = 'rental_tx'
    __table_args__ = {'schema': 'lab5'}
    
    rental_id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    customer_id: Mapped[int] = mapped_column(Integer, ForeignKey('public.customer.customer_id'))
    inventory_id: Mapped[int] = mapped_column(Integer)
    staff_id: Mapped[int] = mapped_column(Integer)
    status: Mapped[RentalStatus] = mapped_column(Enum(RentalStatus, schema='lab5'))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    
    customer: Mapped["Customer"] = relationship(back_populates="rentals")

def prove_n_plus_1():
    print("\n--- Memulai Q17: N+1 Problem ---")
    with Session(engine) as session:

        customers = session.query(Customer).limit(10).all()

        for c in customers:
            _ = len(c.rentals) 
            
    print("--- Selesai ---")

if __name__ == "__main__":
    prove_n_plus_1()