from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db
from datetime import date

router = APIRouter(
    prefix="/schedules",
    tags=["schedules"]
)


@router.post("/", response_model=schemas.MaintenanceSchedule)
def create_schedule(schedule: schemas.MaintenanceScheduleCreate, db: Session = Depends(get_db)):
    # Prevent multiple active schedules for the same gear.
    # Consider a schedule "active" if it is set for today or in the future.
    existing = (
        db.query(models.MaintenanceSchedule)
        .filter(
            models.MaintenanceSchedule.gear_id == schedule.gear_id,
            models.MaintenanceSchedule.scheduled_date >= date.today(),
        )
        .first()
    )
    if existing is not None:
        raise HTTPException(
            status_code=409,
            detail="This gear already has a pending maintenance schedule. Complete or cancel it before adding another.",
        )

    new_sched = models.MaintenanceSchedule(**schedule.dict())
    db.add(new_sched)
    db.commit()
    db.refresh(new_sched)
    return new_sched


@router.get("/", response_model=List[schemas.MaintenanceSchedule])
def get_schedules(db: Session = Depends(get_db)):
    return db.query(models.MaintenanceSchedule).all()
