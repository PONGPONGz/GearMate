from fastapi import APIRouter, Depends, Query
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
def get_gears(
    sort: str = Query(
        "Name",
        description="Sort gears by one of: Name, Type, Maintenance Date",
        regex="^(Name|Type|Maintenance Date)$",
    ),
    db: Session = Depends(get_db),
):
    """Fetch gears with optional server-side sorting.

    Sorting options map to columns without changing DB schema:
    - Name -> Gear.gear_name ASC
    - Type -> Gear.equipment_type ASC
    - Maintenance Date -> Gear.expiry_date ASC (proxy for next maintenance)
    """
    query = db.query(models.Gear)

    if sort == "Name":
        query = query.order_by(models.Gear.gear_name.asc())
    elif sort == "Type":
        query = query.order_by(models.Gear.equipment_type.asc())
    elif sort == "Maintenance Date":
        # Using expiry_date as a proxy for maintenance-related date without schema changes
        query = query.order_by(models.Gear.expiry_date.asc())

    return query.all()
