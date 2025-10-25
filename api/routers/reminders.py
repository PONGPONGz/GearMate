from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db

router = APIRouter(
    prefix="/reminders",
    tags=["reminders"]
)


@router.post("/", response_model=schemas.MaintenanceReminder)
def create_reminder(reminder: schemas.MaintenanceReminderCreate, db: Session = Depends(get_db)):
    new_reminder = models.MaintenanceReminder(**reminder.dict())
    db.add(new_reminder)
    db.commit()
    db.refresh(new_reminder)
    return new_reminder


@router.get("/", response_model=List[schemas.MaintenanceReminder])
def get_reminders(db: Session = Depends(get_db)):
    return db.query(models.MaintenanceReminder).all()
