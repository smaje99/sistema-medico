from contextlib import contextmanager
import sys

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from core.env import ConnectionOptionsDatabase as db


__connection_string = (
    f'mysql+pymysql://{db.user}:{db.password}@{db.host}:{db.port}/{db.database}'
)

__connect_args__ = { 'check_same_thread': False }

engine = None

try:
    engine = create_engine(__connection_string, echo=True, connect_args=__connect_args__)
except Exception as e:
    sys.exit(f'Can\'t connect to database\n{str(e)}')


SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


Base = declarative_base()


def init_db():
    try:
        Base.metadata.create_all(engine)
    except Exception as e:
        sys.exit(f'Failed to create a database instance\n{str(e)}')


@contextmanager
def get_session():
    with SessionLocal(engine) as session:
        yield session
