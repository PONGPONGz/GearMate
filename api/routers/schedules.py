from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db
from datetime import date, time

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

    new_sched = models.MaintenanceSchedule(
        gear_id=schedule.gear_id,
        scheduled_date=schedule.scheduled_date,
        scheduled_time=schedule.scheduled_time or time(hour=0, minute=0)
    )
    db.add(new_sched)
    db.commit()
    db.refresh(new_sched)
    
    new_reminder = models.MaintenanceReminder(
        gear_id=new_sched.gear_id,
        schedule_id=new_sched.id,
        reminder_date=new_sched.scheduled_date,
        reminder_time=new_sched.scheduled_time or time(hour=0, minute=0),
        message=f"Maintenance scheduled for gear {new_sched.gear_id}",
        sent=False
    )
    db.add(new_reminder)
    db.commit()
    db.refresh(new_reminder)

    return new_sched


@router.get("/", response_model=List[schemas.MaintenanceSchedule])
def get_schedules(db: Session = Depends(get_db)):
    return db.query(models.MaintenanceSchedule).all()
