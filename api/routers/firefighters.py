from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db

router = APIRouter(
    prefix="/firefighters",
    tags=["firefighters"]
)


@router.post("/", response_model=schemas.Firefighter)
def create_firefighter(firefighter: schemas.FirefighterCreate, db: Session = Depends(get_db)):
    # Validate foreign key references
    if firefighter.station_id is not None:
        station = db.query(models.Station).filter(models.Station.id == firefighter.station_id).first()
        if not station:
            raise HTTPException(status_code=400, detail=f"Station with id {firefighter.station_id} does not exist")
    
    if firefighter.department_id is not None:
        department = db.query(models.Department).filter(models.Department.id == firefighter.department_id).first()
        if not department:
            raise HTTPException(status_code=400, detail=f"Department with id {firefighter.department_id} does not exist")
    
    new_firefighter = models.Firefighter(**firefighter.dict())
    db.add(new_firefighter)
    db.commit()
    db.refresh(new_firefighter)
    return new_firefighter


@router.get("/", response_model=List[schemas.Firefighter])
def get_firefighters(db: Session = Depends(get_db)):
    return db.query(models.Firefighter).all()
