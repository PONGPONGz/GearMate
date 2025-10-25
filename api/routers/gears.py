from fastapi import APIRouter, Depends, Query, UploadFile, File
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
import models
import schemas
from dependencies import get_db
import os
import shutil
from pathlib import Path
import uuid

router = APIRouter(
    prefix="/gears",
    tags=["gears"]
)

# Create uploads directory if it doesn't exist
UPLOAD_DIR = Path("uploads/gears")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.post("/", response_model=schemas.Gear)
def create_gear(gear: schemas.GearCreate, db: Session = Depends(get_db)):
    new_gear = models.Gear(**gear.dict())
    db.add(new_gear)
    db.commit()
    db.refresh(new_gear)
    return new_gear


@router.post("/{gear_id}/upload-photo")
async def upload_gear_photo(
    gear_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Upload a photo for a specific gear"""
    # Check if gear exists
    gear = db.query(models.Gear).filter(models.Gear.id == gear_id).first()
    if not gear:
        return {"error": "Gear not found"}, 404
    
    # Validate file type
    allowed_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'}
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in allowed_extensions:
        return {"error": "Invalid file type. Allowed: jpg, jpeg, png, gif, webp"}, 400
    
    # Generate unique filename
    unique_filename = f"{gear_id}_{uuid.uuid4().hex}{file_ext}"
    file_path = UPLOAD_DIR / unique_filename
    
    # Delete old photo if exists
    if gear.photo_url:
        old_file = Path(gear.photo_url)
        if old_file.exists():
            old_file.unlink()
    
    # Save the uploaded file
    try:
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        return {"error": f"Failed to save file: {str(e)}"}, 500
    
    # Update gear with photo URL (web-accessible URL path)
    photo_url = f"/uploads/gears/{unique_filename}"
    gear.photo_url = photo_url
    db.commit()
    db.refresh(gear)
    
    return {
        "message": "Photo uploaded successfully",
        "photo_url": photo_url,
        "gear_id": gear_id
    }


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
