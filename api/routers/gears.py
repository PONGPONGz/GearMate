from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db

router = APIRouter(
    prefix="/gears",
    tags=["gears"]
)


@router.post("/", response_model=schemas.Gear)
def create_gear(gear: schemas.GearCreate, db: Session = Depends(get_db)):
    new_gear = models.Gear(**gear.dict())
    db.add(new_gear)
    db.commit()
    db.refresh(new_gear)
    return new_gear


@router.get("/", response_model=List[schemas.Gear])
def get_gears(db: Session = Depends(get_db)):
    return db.query(models.Gear).all()
