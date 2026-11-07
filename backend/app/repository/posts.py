from app.models import Post
from sqlalchemy import select
from sqlalchemy.orm import Session

def get_all(db: Session) -> list[Post]:
    return list[Post](db.scalars(select(Post)).all())


def get_by_id(db: Session, post_id: int) -> Post | None:
    return db.get(Post, post_id)


def create(db: Session, title: str, content: str, published: bool) -> Post:
    post = Post(title=title, content=content, published=published)
    db.add(post)
    db.commit()
    db.refresh(post)
    return post


def update(db: Session, post: Post, title: str, content: str) -> Post:
    post.title = title
    post.content = content
    db.commit()
    db.refresh(post)
    return post


def delete(db: Session, post: Post) -> None:
    db.delete(post)
    db.commit()
