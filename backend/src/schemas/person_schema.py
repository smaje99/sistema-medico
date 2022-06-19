from datetime import datetime

from pydantic import BaseModel

from utils.types import BloodType, DocumentType, Gender


class Person(BaseModel):
    dni: int
    name: str
    surname: str
    address: str | None
    email: str
    phone: int
    gender: Gender
    birthdate: datetime
    document_type: DocumentType
    blood_type: BloodType | None
    created_at: datetime

    class config:
        orm_model = True
