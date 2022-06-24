from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Text

from database import Base


class User(Base):
    __tablename__ = 'user'

    dni = Column(Integer(unsigned=True),
                 ForeignKey('person.dni'),
                 primary_key=True,
                 nullable=False)
    username = Column(String(50), nullable=False, unique=True)
    password = Column(Text, nullable=False)
    is_active = Column(Boolean(), default=True)
    role = Column(Integer(unsigned=True), ForeignKey('role.id'), nullable=False)
