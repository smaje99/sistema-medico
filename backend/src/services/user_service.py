from abc import ABC

from sqlalchemy import literal
from sqlalchemy.orm import Session

from models import User as UserModel
from schemas.user_schema import User, UserLogin



def __contains_user(db: Session, username: str) -> bool:
    q = (db.query(UserModel)
            .filter(UserModel.username == username))

    return (db.query(literal(True))
            .filter(q.exists())
            .scalar())


def login(db: Session, credentials: UserLogin) -> User:
    if __contains_user(db, credentials.username):
        raise Exception('El usuario no existe en el sistema')

    user = (db.query(UserModel)
            .filter(UserModel.username == credentials.username)
            .first())

    if user.password == credentials.password:
        raise Exception('La contraseña es incorrecta')

    return user
