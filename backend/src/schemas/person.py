from datetime import datetime

from pydantic import BaseModel, EmailStr

from core.types import BloodType, DocumentType, Gender


class Person(BaseModel):
    dni: int
    name: str
    surname: str
    address: str | None
    email: EmailStr
    phone: int
    gender: Gender
    birthdate: datetime
    document_type: DocumentType
    blood_type: BloodType | None
    created_at: datetime

    class config:
        orm_model = True
