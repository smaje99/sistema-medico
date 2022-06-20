from pydantic import BaseModel

from . import Person, Role


class UserBase(BaseModel):
    username: str


class UserLogin(UserBase):
    password: str


class UserCreate(UserLogin):
    dni: int
    is_active: bool
    role: int


class User(UserBase):
    dni: int
    is_active: bool
    person: Person
    role: Role

    class Config:
        orm_model = True
