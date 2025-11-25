from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db

router = APIRouter(
    prefix="/stations",
    tags=["stations"]
)


@router.post("/", response_model=schemas.Station)
def create_station(station: schemas.StationCreate, db: Session = Depends(get_db)):
    # Validate foreign key reference
    if station.department_id is not None:
        department = db.query(models.Department).filter(models.Department.id == station.department_id).first()
        if not department:
            raise HTTPException(status_code=400, detail=f"Department with id {station.department_id} does not exist")
    
    new_station = models.Station(**station.dict())
    db.add(new_station)
    db.commit()
    db.refresh(new_station)
    return new_station


@router.get("/", response_model=List[schemas.Station])
def get_stations(db: Session = Depends(get_db)):
    return db.query(models.Station).all()
