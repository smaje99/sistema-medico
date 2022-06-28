from datetime import datetime

from pydantic import BaseModel, EmailStr, PastDate, PositiveInt

from core.types import BloodType, DocumentType, Gender


class Person(BaseModel):
    dni: PositiveInt
    name: str
    surname: str
    address: str | None
    email: EmailStr
    phone: int
    gender: Gender
    birthdate: PastDate
    document_type: DocumentType
    blood_type: BloodType | None
    created_at: datetime

    class Config:
        orm_model = True
