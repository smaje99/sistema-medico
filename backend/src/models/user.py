from sqlalchemy import Boolean, Column, ForeignKey, Integer, String

from database import Base


class User(Base):
    dni = Column(Integer(unsigned=True),
                 ForeignKey('person.dni'),
                 primary_key=True,
                 nullable=False)
    username = Column(String(), nullable=False, unique=True)
    password = Column(String(), nullable=False)
    is_active = Column(Boolean(), default=True)
    role = Column(Integer(unsigned=True), ForeignKey('role.id'), nullable=False)
