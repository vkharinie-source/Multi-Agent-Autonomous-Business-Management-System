from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.auth_routes import router as auth_router
from routes.employee_routes import router as employee_router
from routes.attendance_routes import router as attendance_router
from routes.inventory_routes import router as inventory_router
from routes.sales_routes import router as sales_router
from routes.reports_routes import router as reports_router
from routes.finance_routes import router as finance_router
from routes.marketing_routes import router as marketing_router
from routes.settings_routes import router as settings_router
from routes.device_routes import router as device_router


app = FastAPI(
    title="Autonomous Business AI Backend",
    description="Backend API for Autonomous Business AI",
    version="1.0.0",
)


# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Authentication
app.include_router(auth_router)

# Employee management
app.include_router(employee_router)

# Attendance and secure QR
app.include_router(attendance_router)

# Employee device registration and approval
app.include_router(device_router)

# Inventory management
app.include_router(inventory_router)

# Sales management
app.include_router(sales_router)

# Business reports
app.include_router(reports_router)

# Finance management
app.include_router(finance_router)

# Marketing management
app.include_router(marketing_router)

# Application settings
app.include_router(settings_router)


@app.get("/")
def home():
    return {
        "message": "Autonomous Business AI Backend Running",
        "status": "online",
    }


@app.get("/health")
def health():
    return {
        "status": "Server Online",
        "database": "MongoDB Connected",
        "version": "1.0.0",
    }


@app.get("/version")
def version():
    return {
        "version": "1.0.0",
    }