from fastapi import FastAPI

from core import events


app = FastAPI(
    title='Sistema Médico API',
    description='Gestión de las operaciones CRUD y lógica de negocio del Sistema Médico',
    version='0.0.1'
)


@app.on_event('startup')
def on_startup():
    events.connect_to_database()
