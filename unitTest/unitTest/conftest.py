# Test Suite Configuration
# This file ensures Python can find the api modules when running tests

import sys
import pytest
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient

# Add the parent directory to the Python path so we can import from api/
# We need to go up two levels: unitTest/unitTest -> unitTest -> gear_mate
project_root = Path(__file__).parent.parent.parent
api_path = project_root / "api"
sys.path.insert(0, str(api_path))

from main import app
from database import Base
from dependencies import get_db
import models
from datetime import date

# Shared Test Database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_gearmate.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db_session():
    """
    Creates a fresh database session for a test.
    """
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(db_session):
    """
    Returns a TestClient that uses the test database.
    """
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()

@pytest.fixture(scope="function")
def test_db_with_dependencies(db_session):
    """
    Pre-populates the database with common dependencies (Department, Station).
    """
    # Create test department
    dept = models.Department(department_name="Test Department", location="Test Location")
    db_session.add(dept)
    db_session.commit()
    db_session.refresh(dept)
    
    # Create test station
    station = models.Station(name="Test Station", location="Test Location", department_id=dept.id)
    db_session.add(station)
    db_session.commit()
    db_session.refresh(station)
    
    # Create test firefighter (inspector)
    firefighter = models.Firefighter(
        name="Inspector Gadget",
        ranks="Inspector",
        email="inspector@test.com",
        phone="555-0000",
        station_id=station.id,
        department_id=dept.id
    )
    db_session.add(firefighter)
    db_session.commit()
    db_session.refresh(firefighter)

    # Create test gear
    gear = models.Gear(
        station_id=station.id,
        gear_name="Test Gear",
        serial_number="SN123456",
        equipment_type="PPE",
        purchase_date=date(2023, 1, 1)
    )
    db_session.add(gear)
    db_session.commit()
    db_session.refresh(gear)

    return db_session
