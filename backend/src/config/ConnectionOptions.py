from typing import NamedTuple


class ConnectionOptions(NamedTuple):
    host: str
    port: str
    user: str
    password: str
    database: str
