from fastapi import APIRouter, Depends, HTTPException
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
    # Validate gear_id
    gear = db.query(models.Gear).filter(models.Gear.id == inspection.gear_id).first()
    if not gear:
        raise HTTPException(status_code=400, detail=f"Gear with id {inspection.gear_id} does not exist")

    # Validate inspector_id
    if inspection.inspector_id is not None:
        inspector = db.query(models.Firefighter).filter(models.Firefighter.id == inspection.inspector_id).first()
        if not inspector:
            raise HTTPException(status_code=400, detail=f"Firefighter with id {inspection.inspector_id} does not exist")

    new_insp = models.Inspection(**inspection.dict())
    db.add(new_insp)
    db.commit()
    db.refresh(new_insp)
    return new_insp


@router.get("/", response_model=List[schemas.Inspection])
def get_inspections(db: Session = Depends(get_db)):
    return db.query(models.Inspection).all()
