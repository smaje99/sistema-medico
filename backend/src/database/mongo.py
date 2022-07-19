from beanie import init_beanie
from motor.motor_asyncio import AsyncIOMotorClient


mongo = None


async def init():
    global mongo

    mongo = AsyncIOMotorClient(
        'mongodb://client:client@127.0.0.1:27017/sistema_medico'
    )

    await init_beanie(mongo.sistema_medico)
