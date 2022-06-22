from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.routes import router
from core import events


app = FastAPI(
    title='Sistema Médico API',
    description='Gestión de las operaciones CRUD y lógica de negocio del Sistema Médico',
    version='0.0.1'
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*']
)


@app.on_event('startup')
def on_startup():
    events.connect_to_database()


app.include_router(router, prefix='/api')
