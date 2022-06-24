from fastapi import HTTPException
from sqlalchemy import literal
from sqlalchemy.orm import Session
from starlette.status import HTTP_400_BAD_REQUEST, HTTP_405_METHOD_NOT_ALLOWED

from .crud_base import CRUDBase
from models import User
from schemas.user import UserLogin, UserCreate, UserUpdate


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
        q = (db.query(User)
                .filter(User.username == username))

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
        q = (db.query(User)
            .filter(User.username == credentials.username)
            .filter(User.password == credentials.password))

        return (db.query(literal(True))
                .filter(q.exists())
                .scalar())

    def get_by_username(self, db: Session, username: str) -> User | None:
        return (db.query(User)
                .filter(User.username == username)
                .first())

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
        if self._contains_user(db, credentials.username):
            raise HTTPException(
                status_code=HTTP_400_BAD_REQUEST,
                detail='El usuario no existe en el sistema'
            )

        if self._is_password_valid(db, credentials):
            raise HTTPException(
                status_code=HTTP_400_BAD_REQUEST,
                detail='La contraseña es incorrecta'
            )

        user = self.get_by_username(db, credentials.username)

        if not user.is_active:
            raise HTTPException(
                status_code=HTTP_400_BAD_REQUEST,
                detail='El usuario está inactivo'
            )

        return user

    def get(self, db: Session, dni: int) ->  User | None:
        return (db.query(User.dni, User.username, User.is_active, User.role)
                .filter(User.dni == dni)
                .first())

    def get_all(
        self, db: Session, *, skip: int = 0, limit: int = 50
    ) -> list[User]:
        return (db.query(User)
                .slice(skip, limit)
                .order_by(User.username.asc())
                .order_by(User.role.asc())
                .order_by(User.is_active.desc())
                .all())

    def reset_password(self, db: Session, user_id: int, new_password: str):
        user = self.get(db, user_id)

        if user is None:
            raise HTTPException(
                status_code=HTTP_400_BAD_REQUEST,
                detail='El usuario no existe en el sistema'
            )

        user.password = new_password

        db.add(user)
        db.commit()

    def recover_password(self, db: Session, username: str):
        raise HTTPException(
            status_code=HTTP_405_METHOD_NOT_ALLOWED,
            detail='Method not allowed'
        )

user = UserService(User)
