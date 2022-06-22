from abc import ABC

from fastapi import HTTPException
from sqlalchemy import literal
from sqlalchemy.orm import Session
from starlette.status import HTTP_400_BAD_REQUEST

from crud_base import CRUDBase
from models import User
from schemas.user_schema import UserLogin, UserCreate, UserUpdate


class UserService(CRUDBase[User, UserCreate, UserUpdate]):
    def _contains_user(self, db: Session, username: str) -> bool:
        """
        Returns True if the user exists in the database, False otherwise

        :param db: Session = Depends(get_db)
        :type db: Session
        :param username: str
        :type username: str
        :return: A boolean value.
        """
        q = (db.query(UserModel)
                .filter(UserModel.username == username))

        return (db.query(literal(True))
                .filter(q.exists())
                .scalar())

    def _is_password_valid(self, db: Session, credentials: UserLogin) -> bool:
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

    def login(self, db: Session, credentials: UserLogin) -> User:
        """
        If the user doesn't exist, throw an exception. If the password is invalid, throw an exception.
        Otherwise, return the user.

        :param db: Session = Depends(get_db)
        :type db: Session
        :param credentials: UserLogin = UserLogin(username='username', password='password')
        :type credentials: UserLogin
        :return: The user object
        """
        if _contains_user(db, credentials.username):
            raise HTTPException(
                status_code=HTTP_400_BAD_REQUEST,
                detail='El usuario no existe en el sistema'
            )

        if _is_password_valid(db, credentials):
            raise HTTPException(
                status_code=HTTP_400_BAD_REQUEST
                detail: 'La contraseña es incorrecta'
            )

        return self.get_by_username(db, username=credentials.username)


user = UserService(User)
