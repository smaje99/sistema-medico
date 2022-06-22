from pydantic import BaseModel

from . import Person, Role


class UserBase(BaseModel):
    username: str


class UserLogin(UserBase):
    password: str


class UserCreate(UserLogin):
    dni: int
    role: int


class UserUpdate(UserLogin):
    username: str | None = None
    password: str | None = None
    is_active: bool | None = True
    role: int | None = None


class User(UserBase):
    dni: int
    is_active: bool
    person: Person
    role: Role

    class Config:
        orm_model = True
