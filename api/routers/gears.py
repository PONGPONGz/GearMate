from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
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
    - Maintenance Date -> next scheduled maintenance date from MaintenanceSchedule
    """
    # Subquery to get the earliest scheduled maintenance date for each gear
    maintenance_subquery = (
        db.query(
            models.MaintenanceSchedule.gear_id,
            func.min(models.MaintenanceSchedule.scheduled_date).label('next_maintenance_date')
        )
        .group_by(models.MaintenanceSchedule.gear_id)
        .subquery()
    )
    
    # Main query with left join to include maintenance dates
    query = (
        db.query(
            models.Gear,
            maintenance_subquery.c.next_maintenance_date
        )
        .outerjoin(
            maintenance_subquery,
            models.Gear.id == maintenance_subquery.c.gear_id
        )
    )

    # Apply sorting
    if sort == "Name":
        query = query.order_by(models.Gear.gear_name.asc())
    elif sort == "Type":
        query = query.order_by(models.Gear.equipment_type.asc())
    elif sort == "Maintenance Date":
        query = query.order_by(maintenance_subquery.c.next_maintenance_date.asc())

    results = query.all()
    
    # Build response with next_maintenance_date included
    gears = []
    for gear, next_maintenance in results:
        gear_dict = {
            'id': gear.id,
            'station_id': gear.station_id,
            'gear_name': gear.gear_name,
            'serial_number': gear.serial_number,
            'photo_url': gear.photo_url,
            'equipment_type': gear.equipment_type,
            'purchase_date': gear.purchase_date,
            'expiry_date': gear.expiry_date,
            'next_maintenance_date': next_maintenance,
        }
        gears.append(gear_dict)
    
    return gears
