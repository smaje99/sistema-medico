from fastapi import FastAPI

from config.database import create_db


create_db()


app = FastAPI(
    title='Sistema Médico API',
    description='Gestión de las operaciones CRUD y lógica de negocio del Sistema Médico',
    version='0.0.1'
)
