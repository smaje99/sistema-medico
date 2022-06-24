from sqlalchemy import Column, Integer, String

from database import Base


class Role(Base):
    __tablename__ = 'role'

    id = Column(Integer, primary_key=True, nullable=False)
    name = Column(String(50), nullable=False, unique=True)
