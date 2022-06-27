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
async def login(credentials: UserLogin = Body( ... ), db: Session = Depends(get_db)):
    user = service.login(db, credentials)

    return user


@router.post('/password-recovery/{username}', status_code=HTTP_202_ACCEPTED)
async def recover_password(username: str, db: Session = Depends(get_db)):
    service.recover_password(db, username)


@router.post('/password-reset', status_code=HTTP_204_NO_CONTENT)
async def reset_password(
    user_id: int = Body(..., gt=0),
    new_password: str = Body( ... ),
    db: Session = Depends(get_db)
):
    service.reset_password(db, user_id, new_password)
