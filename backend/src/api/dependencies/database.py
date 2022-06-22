from typing import Generator

from sqlalchemy.orm import Session

from database import SessionLocal


def get_db() -> Generator[Session, None, None]:
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()
