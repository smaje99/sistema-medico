import sys

from database.database import engine
from database import Base


def init_db():
    try:
        Base.metadata.create_all(engine)
    except Exception as e:
        sys.exit(f'Failed to create a database instance\n{str(e)}')
