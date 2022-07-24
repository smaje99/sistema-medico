from sqlalchemy import BigInteger, Column, ForeignKey
from sqlalchemy.orm import relationship

from database import Base


class Patient(Base):
    dni = Column(
        BigInteger,
        ForeignKey('person.person.dni'),
        primary_key=True,
        nullable=False
    )

    __table_args__ = { 'schema': 'patient' }
