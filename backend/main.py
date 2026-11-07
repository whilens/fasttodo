from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.operations import router as operations_router
from app.database import Base, engine
from app.models import Post  # noqa: F401  — регистрирует таблицу в Base.metadata

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:5174",
        "http://localhost:3000",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:5174",
        "http://127.0.0.1:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(operations_router, prefix="/api/v1", tags=["operations"])

Base.metadata.create_all(bind=engine)
