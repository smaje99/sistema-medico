from contextlib import contextmanager
import sys

from sqlmodel import SQLModel, Session, create_engine

from .env import ConnectionOptionsDatabase as db


__connection_string = (
    f'mysql+pymysql://{db.user}:{db.password}@{db.host}:{db.port}/{db.database}'
)

__connect_args__ = { 'check_same_thread': False }

engine = None

try:
    engine = create_engine(__connection_string, connect_args=__connect_args__)
except Exception as e:
    sys.exit(f'Can\'t connect to database\n{str(e)}')


def create_db():
    try:
        SQLModel.metadata.create_all(engine)
    except Exception as e:
        sys.exit(f'Failed to create a database instance\n{str(e)}')


@contextmanager
def get_session():
    with Session(engine) as session:
        yield session
