import sys

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from core.config import settings


engine = None

try:
    engine = create_engine(settings.SQLALCHEMY_DATABASE_URI, echo=True)
except Exception as e:
    sys.exit(f'Can\'t connect to database\n{str(e)}')


SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
