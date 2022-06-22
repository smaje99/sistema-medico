from fastapi import APIRouter, Body, Depends, HTTPException
from sqlalchemy.orm import Session
from starlette.status import HTTP_400_BAD_REQUEST

from api.dependencies.database import get_db
from schemas.user import User, UserLogin
from services.user_service import user as service


router = APIRouter()


@router.post('/login', response_model=User)
def login(credentials: UserLogin = Body( ... ), db: Session = Depends(get_db)):
    user = service.login(db, credentials)

    return user


@router.post('password-recovery')
def recover_password(username: str = Body( ... ), db: Service = Depends(get_db)):
    pass


def reset_password(
    username: str = Body( ... ),
    new_password: str = Body( ... ),
    db: Service = Depends(get_db)
):
    pass
