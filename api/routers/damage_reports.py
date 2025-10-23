from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db

router = APIRouter(
    prefix="/damage-reports",
    tags=["damage-reports"]
)


@router.post("/", response_model=schemas.DamageReport)
def create_damage_report(report: schemas.DamageReportCreate, db: Session = Depends(get_db)):
    new_report = models.DamageReport(**report.dict())
    db.add(new_report)
    db.commit()
    db.refresh(new_report)
    return new_report


@router.get("/", response_model=List[schemas.DamageReport])
def get_damage_reports(db: Session = Depends(get_db)):
    return db.query(models.DamageReport).all()
