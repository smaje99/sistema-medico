from abc import ABC, abstractmethod
from typing import Any, Generic, Type, TypeVar

from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
from sqlalchemy.orm import Session

from database import Base


ModelType = TypeVar('ModelType', bound=Base)
CreateSchemaType = TypeVar('CreateSchemaType', bound=BaseModel)
UpdateSchemaType = TypeVar('UpdateSchemaType', bound=BaseModel)


class BaseRepository(ABC, Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    def __init__(self, model: Type[ModelType]):
        self.model = model

    def get(self, db: Session, id: Any) -> ModelType | None:
        return db.query(self.model).get(id)

    def list(
        self, db: Session, *, skip: int = 0, limit: int = 50
    ) -> list[ModelType]:
        return (db.query(self.model)
                .offset(skip)
                .limit(limit)
                .all())

    def add(self, db: Session, *, data_in: CreateSchemaType) -> ModelType:
        db_data = self.model(**jsonable_encoder(data_in))

        db.add(db_data)
        db.commit()
        db.refresh(db_data)

        return db_data

    def update(
        self,
        db: Session,
        *,
        db_data: ModelType,
        data_in: UpdateSchemaType | dict[str, Any]
    ) -> ModelType:
        obj_data = jsonable_encoder(db_data)

        update_data = (data_in
                       if isinstance(data_in, dict) else
                       data_in.dict(exclude_unset=True))

        for field in obj_data:
            if field in update_data:
                setattr(db_data, field, update_data[field])

        db.add(db_data)
        db.commit()
        db.refresh(db_data)

        return db_data

    def delete(self, db: Session, *, id: Any) -> ModelType:
        data = self.get(db, id)

        db.delete(data)
        db.commit()

        return data
