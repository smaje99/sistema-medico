import os
from pathlib import Path

from dotenv import load_dotenv

from .ConnectionOptions import ConnectionOptions


__dir = os.path.dirname(__file__)
__path = os.path.join(__dir, '..', '..', '.env')
__dotenv_path = Path(__path).resolve()

load_dotenv(dotenv=__dotenv_path)


ConnectionOptionsDatabase = ConnectionOptions(
    os.getenv('DB_HOST'),
    os.getenv('DB_PORT'),
    os.getenv('DB_UID'),
    os.getenv('DB_PWD'),
    os.getenv('DB_DB')
)
