from pydantic import BaseModel, field_validator
from datetime import date, time
from typing import Optional, List

class DepartmentBase(BaseModel):
    department_name: str
    location: Optional[str] = None


class DepartmentCreate(DepartmentBase):
    pass


class Department(DepartmentBase):
    id: int

    class Config:
        orm_mode = True


class StationBase(BaseModel):
    name: str
    location: Optional[str] = None
    department_id: Optional[int] = None


class StationCreate(StationBase):
    pass


class Station(StationBase):
    id: int

    class Config:
        orm_mode = True


class FirefighterBase(BaseModel):
    name: str
    ranks: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    station_id: Optional[int] = None
    department_id: Optional[int] = None

    @field_validator('name')
    @classmethod
    def name_must_not_be_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('name cannot be empty')
        return v

    @field_validator('station_id', 'department_id')
    @classmethod
    def ids_must_be_positive(cls, v: Optional[int]) -> Optional[int]:
        if v is not None and v < 0:
            raise ValueError('ID must be a positive integer')
        return v


class FirefighterCreate(FirefighterBase):
    pass


class Firefighter(FirefighterBase):
    id: int

    class Config:
        orm_mode = True


class GearBase(BaseModel):
    station_id: int
    gear_name: str
    serial_number: Optional[str] = None
    photo_url: Optional[str] = None
    equipment_type: Optional[str] = None
    purchase_date: Optional[date] = None
    expiry_date: Optional[date] = None


class GearCreate(GearBase):
    pass


class Gear(GearBase):
    id: int
    next_maintenance_date: Optional[date] = None

    class Config:
        orm_mode = True


class InspectionBase(BaseModel):
    gear_id: int
    inspection_date: Optional[date] = None
    inspector_id: Optional[int] = None
    inspection_type: Optional[str] = None
    condition_notes: Optional[str] = None
    result: Optional[str] = None


class InspectionCreate(InspectionBase):
    pass


class Inspection(InspectionBase):
    id: int

    class Config:
        orm_mode = True


class MaintenanceScheduleBase(BaseModel):
    gear_id: int
    scheduled_date: Optional[date] = None
    scheduled_time: Optional[time] = None

class MaintenanceScheduleCreate(MaintenanceScheduleBase):
    pass


class MaintenanceSchedule(MaintenanceScheduleBase):
    id: int

    class Config:
        orm_mode = True


class MaintenanceReminderBase(BaseModel):
    gear_id: int
    reminder_date: Optional[date] = None
    reminder_time: Optional[time] = None
    message: Optional[str] = None
    sent: Optional[bool] = False


class MaintenanceReminderCreate(MaintenanceReminderBase):
    pass


class MaintenanceReminder(MaintenanceReminderBase):
    id: int

    class Config:
        orm_mode = True


class DamageReportBase(BaseModel):
    gear_id: int
    reporter_id: Optional[int] = None
    report_date: Optional[date] = None
    notes: Optional[str] = None
    photo_url: Optional[str] = None
    status: Optional[str] = None


class DamageReportCreate(BaseModel):
    gear_id: int
    reporter_name: Optional[str] = None
    report_date: Optional[date] = None
    notes: Optional[str] = None
    photo_url: Optional[str] = None
    status: Optional[str] = None


class DamageReport(DamageReportBase):
    id: int
    gear_name: Optional[str] = None
    reporter_name: Optional[str] = None

    class Config:
        orm_mode = True
