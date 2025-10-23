from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from dependencies import get_db

router = APIRouter(
    prefix="/inspections",
    tags=["inspections"]
)


@router.post("/", response_model=schemas.Inspection)
def create_inspection(inspection: schemas.InspectionCreate, db: Session = Depends(get_db)):
    new_insp = models.Inspection(**inspection.dict())
    db.add(new_insp)
    db.commit()
    db.refresh(new_insp)
    return new_insp


@router.get("/", response_model=List[schemas.Inspection])
def get_inspections(db: Session = Depends(get_db)):
    return db.query(models.Inspection).all()
