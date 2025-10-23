from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db

router = APIRouter(
    prefix="/schedules",
    tags=["schedules"]
)


@router.post("/", response_model=schemas.MaintenanceSchedule)
def create_schedule(schedule: schemas.MaintenanceScheduleCreate, db: Session = Depends(get_db)):
    new_sched = models.MaintenanceSchedule(**schedule.dict())
    db.add(new_sched)
    db.commit()
    db.refresh(new_sched)
    return new_sched


@router.get("/", response_model=List[schemas.MaintenanceSchedule])
def get_schedules(db: Session = Depends(get_db)):
    return db.query(models.MaintenanceSchedule).all()
