from sqlalchemy import (
    Column, Integer, String, Date, Boolean, ForeignKey, Text, Time
)
from sqlalchemy.orm import relationship
from database import Base

class Department(Base):
    __tablename__ = "department"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    department_name = Column(String(100), nullable=False)
    location = Column(String(150))

    stations = relationship("Station", back_populates="department")
    firefighters = relationship("Firefighter", back_populates="department")


class Station(Base):
    __tablename__ = "station"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    location = Column(String(150))
    department_id = Column(Integer, ForeignKey("department.id"))

    department = relationship("Department", back_populates="stations")
    firefighters = relationship("Firefighter", back_populates="station")
    gears = relationship("Gear", back_populates="station")


class Firefighter(Base):
    __tablename__ = "firefighter"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    ranks = Column(String(50))
    email = Column(String(100))
    phone = Column(String(20))
    station_id = Column(Integer, ForeignKey("station.id"))
    department_id = Column(Integer, ForeignKey("department.id"))

    station = relationship("Station", back_populates="firefighters")
    department = relationship("Department", back_populates="firefighters")
    inspections = relationship("Inspection", back_populates="inspector")
    damage_reports = relationship("DamageReport", back_populates="reporter")


class Gear(Base):
    __tablename__ = "gear"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    station_id = Column(Integer, ForeignKey("station.id"), nullable=False)
    gear_name = Column(String(100), nullable=False)
    serial_number = Column(String(100), unique=True)
    equipment_type = Column(String(100))
    purchase_date = Column(Date)
    expiry_date = Column(Date)
    status = Column(String(50))

    station = relationship("Station", back_populates="gears")
    inspections = relationship("Inspection", back_populates="gear")
    maintenance_schedules = relationship("MaintenanceSchedule", back_populates="gear")
    maintenance_reminders = relationship("MaintenanceReminder", back_populates="gear")
    damage_reports = relationship("DamageReport", back_populates="gear")


class Inspection(Base):
    __tablename__ = "inspection"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    gear_id = Column(Integer, ForeignKey("gear.id"))
    date = Column(Date)
    inspector_id = Column(Integer, ForeignKey("firefighter.id"))
    inspection_type = Column(String(100))
    condition_notes = Column(Text)
    result = Column(String(50))

    gear = relationship("Gear", back_populates="inspections")
    inspector = relationship("Firefighter", back_populates="inspections")


class MaintenanceSchedule(Base):
    __tablename__ = "maintenance_schedule"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    gear_id = Column(Integer, ForeignKey("gear.id"))
    scheduled_date = Column(Date)
    frequency = Column(String(50))
    shared_across_department = Column(Boolean, default=False)

    gear = relationship("Gear", back_populates="maintenance_schedules")


class MaintenanceReminder(Base):
    __tablename__ = "maintenance_reminder"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    gear_id = Column(Integer, ForeignKey("gear.id"))
    reminder_date = Column(Date)
    reminder_time = Column(Time)
    message = Column(String(255))
    sent = Column(Boolean, default=False)

    gear = relationship("Gear", back_populates="maintenance_reminders")


class DamageReport(Base):
    __tablename__ = "damage_report"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    gear_id = Column(Integer, ForeignKey("gear.id"))
    reporter_id = Column(Integer, ForeignKey("firefighter.id"))
    report_date = Column(Date)
    notes = Column(Text)
    photo_url = Column(String(255))
    status = Column(String(50))

    gear = relationship("Gear", back_populates="damage_reports")
    reporter = relationship("Firefighter", back_populates="damage_reports")