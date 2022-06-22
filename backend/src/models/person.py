from datetime import datetime

from sqlalchemy import Column, DateTime, Enum, Integer, String, TIMESTAMP

from database import Base
from core.types import BloodType, DocumentType, Gender


class Person(Base):
    __tablename__ = 'person'

    dni = Column(Integer(unsigned=True), primary_key=True, nullable=False)
    name = Column(String(), nullable=False)
    surname = Column(String(), nullable=False)
    address = Column(String())
    email = Column(String(), nullable=False, unique=True)
    phone = Column(Integer(), nullable=False)
    gender = Column(Enum(Gender), nullable=False)
    birthdate = Column(DateTime(), nullable=False)
    document_type = Column(Enum(DocumentType), nullable=False)
    blood_type = Column(Enum(BloodType))
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.now())
