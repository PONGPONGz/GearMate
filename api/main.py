from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import models
from database import engine
from pathlib import Path

# Import routers
from routers import departments, stations, firefighters, gears, inspections, schedules, reminders
from routers import damage_reports


app = FastAPI(title="GearMate API", version="1.0.0")

# DB tables
models.Base.metadata.create_all(bind=engine)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for uploaded images
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(UPLOAD_DIR)), name="uploads")


@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Welcome to GearMate API"}


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


# Include routers
app.include_router(departments.router)
app.include_router(stations.router)
app.include_router(firefighters.router)
app.include_router(gears.router)
app.include_router(inspections.router)
app.include_router(schedules.router)
app.include_router(reminders.router)
app.include_router(damage_reports.router)
