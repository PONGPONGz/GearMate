from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from database import engine, SessionLocal




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

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Welcome to GearMate API"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

# Department Endpoints
@app.post("/departments/", response_model=schemas.Department)
def create_department(dept: schemas.DepartmentCreate, db: Session = Depends(get_db)):
    new_dept = models.Department(**dept.dict())
    db.add(new_dept)
    db.commit()
    db.refresh(new_dept)
    return new_dept


@app.get("/departments/", response_model=List[schemas.Department])
def get_departments(db: Session = Depends(get_db)):
    return db.query(models.Department).all()


# Station Endpoints
@app.post("/stations/", response_model=schemas.Station)
def create_station(station: schemas.StationCreate, db: Session = Depends(get_db)):
    new_station = models.Station(**station.dict())
    db.add(new_station)
    db.commit()
    db.refresh(new_station)
    return new_station


@app.get("/stations/", response_model=List[schemas.Station])
def get_stations(db: Session = Depends(get_db)):
    return db.query(models.Station).all()


# Firefighter Endpoints
@app.post("/firefighters/", response_model=schemas.Firefighter)
def create_firefighter(firefighter: schemas.FirefighterCreate, db: Session = Depends(get_db)):
    new_firefighter = models.Firefighter(**firefighter.dict())
    db.add(new_firefighter)
    db.commit()
    db.refresh(new_firefighter)
    return new_firefighter


@app.get("/firefighters/", response_model=List[schemas.Firefighter])
def get_firefighters(db: Session = Depends(get_db)):
    return db.query(models.Firefighter).all()


# Gear Endpoints
@app.post("/gears/", response_model=schemas.Gear)
def create_gear(gear: schemas.GearCreate, db: Session = Depends(get_db)):
    new_gear = models.Gear(**gear.dict())
    db.add(new_gear)
    db.commit()
    db.refresh(new_gear)
    return new_gear


@app.get("/gears/", response_model=List[schemas.Gear])
def get_gears(db: Session = Depends(get_db)):
    return db.query(models.Gear).all()


# Inspection Endpoints
@app.post("/inspections/", response_model=schemas.Inspection)
def create_inspection(inspection: schemas.InspectionCreate, db: Session = Depends(get_db)):
    new_insp = models.Inspection(**inspection.dict())
    db.add(new_insp)
    db.commit()
    db.refresh(new_insp)
    return new_insp


@app.get("/inspections/", response_model=List[schemas.Inspection])
def get_inspections(db: Session = Depends(get_db)):
    return db.query(models.Inspection).all()


# Maintenance Schedule Endpoints
@app.post("/schedules/", response_model=schemas.MaintenanceSchedule)
def create_schedule(schedule: schemas.MaintenanceScheduleCreate, db: Session = Depends(get_db)):
    new_sched = models.MaintenanceSchedule(**schedule.dict())
    db.add(new_sched)
    db.commit()
    db.refresh(new_sched)
    return new_sched


@app.get("/schedules/", response_model=List[schemas.MaintenanceSchedule])
def get_schedules(db: Session = Depends(get_db)):
    return db.query(models.MaintenanceSchedule).all()


# Maintenance Reminder Endpoints
@app.post("/reminders/", response_model=schemas.MaintenanceReminder)
def create_reminder(reminder: schemas.MaintenanceReminderCreate, db: Session = Depends(get_db)):
    new_reminder = models.MaintenanceReminder(**reminder.dict())
    db.add(new_reminder)
    db.commit()
    db.refresh(new_reminder)
    return new_reminder


@app.get("/reminders/", response_model=List[schemas.MaintenanceReminder])
def get_reminders(db: Session = Depends(get_db)):
    return db.query(models.MaintenanceReminder).all()


# Damage Report Endpoints
@app.post("/damage-reports/", response_model=schemas.DamageReport)
def create_damage_report(report: schemas.DamageReportCreate, db: Session = Depends(get_db)):
    new_report = models.DamageReport(**report.dict())
    db.add(new_report)
    db.commit()
    db.refresh(new_report)
    return new_report


@app.get("/damage-reports/", response_model=List[schemas.DamageReport])
def get_damage_reports(db: Session = Depends(get_db)):
    return db.query(models.DamageReport).all()