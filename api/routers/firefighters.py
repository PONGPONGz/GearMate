from fastapi import APIRouter, Depends
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
    new_firefighter = models.Firefighter(**firefighter.dict())
    db.add(new_firefighter)
    db.commit()
    db.refresh(new_firefighter)
    return new_firefighter


@router.get("/", response_model=List[schemas.Firefighter])
def get_firefighters(db: Session = Depends(get_db)):
    return db.query(models.Firefighter).all()
