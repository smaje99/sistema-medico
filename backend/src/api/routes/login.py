from fastapi import APIRouter, Body, Depends, HTTPException
from sqlalchemy.orm import Session
from starlette.status import (
    HTTP_400_BAD_REQUEST, HTTP_202_ACCEPTED, HTTP_204_NO_CONTENT
)

from api.dependencies.database import get_db
from schemas.user import User, UserLogin
from services.user_service import user as service


router = APIRouter()


@router.post('/login', response_model=User)
def login(credentials: UserLogin = Body( ... ), db: Session = Depends(get_db)):
    user = service.login(db, credentials)

    return user


@router.post('/password-recovery', status_code=HTTP_202_ACCEPTED)
def recover_password(username: str = Body( ... ), db: Session = Depends(get_db)):
    service.recover_password()


@router.post('/password-reset', status_code=HTTP_204_NO_CONTENT)
def reset_password(
    user_id: int = Body( ... ),
    new_password: str = Body( ... ),
    db: Session = Depends(get_db)
):
    service.reset_password(db, user_id, new_password)
