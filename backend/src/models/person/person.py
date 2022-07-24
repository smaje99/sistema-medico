from sqlalchemy import BigInteger, Column, DateTime, Enum, Text
from sqlalchemy.orm import relationship

from core.types import BloodType, DocumentType, Gender
from database import Base

from models.patient import Patient


class Person(Base):
    dni = Column(BigInteger, primary_key=True, nullable=False)
    name = Column(Text, nullable=False)
    surname = Column(Text, nullable=False)
    address = Column(Text)
    email = Column(Text, nullable=False)
    phone = Column(BigInteger, nullable=False)
    gender = Column(Enum(Gender), nullable=False)
    birthdate = Column(DateTime, nullable=False)
    document_type = Column(
        Enum(DocumentType, values_callable=lambda obj: [e.value for e in obj]),
        nullable=False
    )
    blood_type = Column(
        Enum(BloodType, values_callable=lambda obj: [e.value for e in obj]),
        nullable=False
    )

    patient = relationship(Patient, back_populates='person', uselist=False)

    __table_args__ = { 'schema': 'person' }
