from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app import schemas
from app.api.service import operations as operations_service
from app.database import get_db

router = APIRouter()


@router.get("/posts", response_model=list[schemas.PostResponse])
def get_posts(db: Session = Depends(get_db)):
    return operations_service.get_posts(db)


@router.post("/posts", response_model=schemas.PostResponse)
def create_post(body: schemas.PostCreate, db: Session = Depends(get_db)):
    return operations_service.create_post(db, body)


@router.put("/posts/{id}", response_model=schemas.PostResponse)
def update_post(id: int, body: schemas.PostUpdate, db: Session = Depends(get_db)):
    return operations_service.update_post(db, id, body)


@router.delete("/posts/{id}")
def delete_post(id: int, db: Session = Depends(get_db)):
    return operations_service.delete_post(db, id)
