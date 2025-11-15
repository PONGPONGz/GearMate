from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload
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
    # Look up firefighter by name if provided
    reporter_id = None
    if report.reporter_name:
        firefighter = db.query(models.Firefighter).filter(
            models.Firefighter.name == report.reporter_name
        ).first()
        if firefighter:
            reporter_id = firefighter.id
    
    # Create damage report with the found reporter_id
    report_data = report.dict(exclude={'reporter_name'})
    report_data['reporter_id'] = reporter_id
    
    new_report = models.DamageReport(**report_data)
    db.add(new_report)
    db.commit()
    db.refresh(new_report)
    return new_report


@router.get("/", response_model=List[schemas.DamageReport])
def get_damage_reports(db: Session = Depends(get_db)):
    reports = db.query(models.DamageReport).options(
        joinedload(models.DamageReport.gear),
        joinedload(models.DamageReport.reporter)
    ).all()
    
    # Add gear_name and reporter_name to response
    result = []
    for report in reports:
        report_dict = {
            "id": report.id,
            "gear_id": report.gear_id,
            "reporter_id": report.reporter_id,
            "report_date": report.report_date,
            "notes": report.notes,
            "photo_url": report.photo_url,
            "status": report.status,
            "gear_name": report.gear.gear_name if report.gear else None,
            "reporter_name": report.reporter.name if report.reporter else None,
        }
        result.append(report_dict)
    
    return result
