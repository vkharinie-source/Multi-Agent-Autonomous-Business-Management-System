from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config.database import db
from routes.employee_routes import router as employee_router

app = FastAPI(
    title="Autonomous Business AI Backend",
    description="Backend API for Autonomous Business AI",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(employee_router)


@app.get("/")
def home():
    return {
        "message": "Autonomous Business AI Backend Running"
    }


@app.get("/health")
def health():
    return {
        "status": "Server Online",
        "database": "MongoDB Connected",
    }


@app.get("/version")
def version():
    return {
        "version": "1.0.0"
    }