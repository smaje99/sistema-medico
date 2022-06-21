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


def __is_password_valid(db: Session, credentials: UserLogin) -> bool:
    """
    If the username and password match a user in the database,
    return True, otherwise return False.

    :param db: Session = Depends(get_db)
    :type db: Session
    :param credentials: UserLogin
    :type credentials: UserLogin
    :return: A boolean value.
    """
    q = (db.query(UserModel)
         .filter(UserModel.username == credentials.username)
         .filter(UserModel.password == credentials.password))

    return (db.query(literal(True))
            .filter(q.exists())
            .scalar())


def login(db: Session, credentials: UserLogin) -> User:
    if __contains_user(db, credentials.username):
        raise Exception('El usuario no existe en el sistema')

    if __is_password_valid(db, credentials):
        raise Exception('La contraseña es incorrecta')

    return user
