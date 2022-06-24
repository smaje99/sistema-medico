from datetime import datetime

from sqlalchemy import Column, DateTime, Enum, Integer, TIMESTAMP, Text
from sqlalchemy.orm import relationship

from database import Base
from core.types import BloodType, DocumentType, Gender


class Person(Base):
    __tablename__ = 'person'

    dni = Column(Integer(unsigned=True), primary_key=True, nullable=False)
    name = Column(Text, nullable=False)
    surname = Column(Text, nullable=False)
    address = Column(Text)
    email = Column(Text, nullable=False, unique=True)
    phone = Column(Integer(), nullable=False)
    gender = Column(Enum(Gender), nullable=False)
    birthdate = Column(DateTime(), nullable=False)
    document_type = Column(Enum(DocumentType), nullable=False)
    blood_type = Column(Enum(BloodType))
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.now())

    user = relationship('User', back_populates='parent', uselist=False)
