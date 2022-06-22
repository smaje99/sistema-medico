from fastapi import APIRouter

from api.routes import login


router = APIRouter()

router.include_router(login.router, tags=['login'])
