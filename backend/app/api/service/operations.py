from fastapi import HTTPException
from sqlalchemy.orm import Session

from app import schemas
from app.repository import posts as posts_repo


def get_posts(db: Session):
    return posts_repo.get_all(db)


def create_post(db: Session, body: schemas.PostCreate):
    return posts_repo.create(db, body.title, body.content, body.published)


def update_post(db: Session, id: int, body: schemas.PostUpdate):
    post = posts_repo.get_by_id(db, id)
    if post is None:
        raise HTTPException(status_code=404, detail="Post not found")
    return posts_repo.update(db, post, body.title, body.content)


def delete_post(db: Session, id: int):
    post = posts_repo.get_by_id(db, id)
    if post is None:
        raise HTTPException(status_code=404, detail="Post not found")
    posts_repo.delete(db, post)
    return {"detail": "Post deleted"}
