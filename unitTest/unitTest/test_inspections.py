"""
Inspections Router Tests
Tests for /inspections endpoints using Base Choice Coverage ISP

Testing Strategy:
- Base Choice Input Space Partitioning (ISP)
- 1 Base test with typical/valid values
- Variations testing one parameter change at a time
- Focuses on realistic failure scenarios
- Uses FastAPI TestClient for real HTTP requests

Total Test Cases: 17 (1 base + 16 variations)

Base Choice Coverage - Selected Characteristics:
1. gear_id (required field)
   - Base: Valid positive integer (1)
   - Variations: None, Non-existent FK, Negative

2. inspection_date (optional field)
   - Base: Valid date string '2025-11-20'
   - Variations: None, Past date, Future date

3. inspector_id (optional field, FK to firefighter)
   - Base: Valid positive integer (1)
   - Variations: None, Non-existent FK, Negative

4. inspection_type (optional field)
   - Base: 'Annual'
   - Variations: None, Various types (Annual, Monthly)

5. condition_notes (optional text field)
   - Base: Normal text 'Equipment in good condition'
   - Variations: None, Empty string, text

6. result (optional field)
   - Base: 'Pass'
   - Variations: None, Various statuses (Pass, Fail, Needs Repair, Retired)
"""
import pytest
import sys
from pathlib import Path
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Add api directory to path
api_path = Path(__file__).parent.parent.parent / "api"
sys.path.insert(0, str(api_path))

from main import app
from database import Base
from dependencies import get_db
import models

# Test database setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_inspections.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    """Override database dependency for testing"""
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


@pytest.fixture(scope="function")
def test_db():
    """Create fresh database for each test"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def test_db_with_dependencies():
    """Create fresh database with department, station, firefighter, and gear for FK tests"""
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    
    # Create test department
    dept = models.Department(department_name="Test Department", location="Test Location")
    db.add(dept)
    db.commit()
    db.refresh(dept)
    
    # Create test station
    station = models.Station(name="Test Station", location="Test Location", department_id=dept.id)
    db.add(station)
    db.commit()
    db.refresh(station)
    
    # Create test firefighter (inspector)
    firefighter = models.Firefighter(
        name="Test Inspector", 
        ranks="Captain",
        station_id=station.id,
        department_id=dept.id
    )
    db.add(firefighter)
    db.commit()
    db.refresh(firefighter)
    
    # Create test gear
    gear = models.Gear(
        station_id=station.id,
        gear_name="Test Gear",
        serial_number="SN-12345",
        equipment_type="SCBA"
    )
    db.add(gear)
    db.commit()
    db.refresh(gear)
    
    db.close()
    yield
    Base.metadata.drop_all(bind=engine)


class TestInspectionPostEndpoint:
    """Base Choice Coverage tests for POST /inspections endpoint"""

    # BASE TEST: All valid typical values
    def test_base_all_valid_values(self, test_db_with_dependencies):
        """Base test: Valid inspection with all fields populated with typical values"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()

    # GEAR_ID VARIATIONS (3 tests)
    def test_gear_id_none(self, test_db_with_dependencies):
        """Variation: gear_id is None (should fail as required field)"""
        payload = {
            'gear_id': None,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        # None for required field should fail validation
        assert response.status_code == 422

    def test_gear_id_non_existent(self, test_db_with_dependencies):
        """Variation: gear_id references non-existent gear (FK violation)"""
        payload = {
            'gear_id': 9999,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        # Foreign key violation should result in 500 error (SQLite behavior)
        assert response.status_code == 500

    def test_gear_id_negative(self, test_db_with_dependencies):
        """Variation: gear_id is negative (invalid value)"""
        payload = {
            'gear_id': -1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        # Negative ID should cause FK violation
        assert response.status_code == 500

    # INSPECTION_DATE VARIATIONS (3 tests)
    def test_inspection_date_none(self, test_db_with_dependencies):
        """Variation: inspection_date is None (optional field)"""
        payload = {
            'gear_id': 1,
            'inspection_date': None,
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['inspection_date'] is None

    def test_inspection_date_past(self, test_db_with_dependencies):
        """Variation: inspection_date in the past"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2020-01-15',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['inspection_date'] == '2020-01-15'

    def test_inspection_date_future(self, test_db_with_dependencies):
        """Variation: inspection_date in the future (scheduled inspection)"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2026-12-31',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['inspection_date'] == '2026-12-31'

    # INSPECTOR_ID VARIATIONS (3 tests)
    def test_inspector_id_none(self, test_db_with_dependencies):
        """Variation: inspector_id is None (optional field)"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': None,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['inspector_id'] is None

    def test_inspector_id_non_existent(self, test_db_with_dependencies):
        """Variation: inspector_id references non-existent firefighter (FK violation)"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 9999,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        # Foreign key violation should result in 500 error
        assert response.status_code == 500

    def test_inspector_id_negative(self, test_db_with_dependencies):
        """Variation: inspector_id is negative (invalid value)"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': -1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        # Negative ID should cause FK violation
        assert response.status_code == 500

    # INSPECTION_TYPE VARIATIONS (2 tests)
    def test_inspection_type_none(self, test_db_with_dependencies):
        """Variation: inspection_type is None (optional field)"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': None,
            'condition_notes': 'Equipment in good condition',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['inspection_type'] is None

    def test_inspection_type_various_types(self, test_db_with_dependencies):
        """Variation: inspection_type with different common types"""
        inspection_types = ['Annual', 'Monthly']
        
        for i, insp_type in enumerate(inspection_types):
            payload = {
                'gear_id': 1,
                'inspection_date': '2025-11-20',
                'inspector_id': 1,
                'inspection_type': insp_type,
                'condition_notes': 'Equipment in good condition',
                'result': 'Pass'
            }
            
            response = client.post("/inspections/", json=payload)
            
            assert response.status_code == 200
            data = response.json()
            assert data['inspection_type'] == insp_type

    # CONDITION_NOTES VARIATIONS (3 tests)
    def test_condition_notes_none(self, test_db_with_dependencies):
        """Variation: condition_notes is None (optional field)"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': None,
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['condition_notes'] is None

    def test_condition_notes_empty_string(self, test_db_with_dependencies):
        """Variation: condition_notes is empty string"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': '',
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['condition_notes'] == ''

    def test_condition_notes_long_text(self, test_db_with_dependencies):
        """Variation: condition_notes with long text and special characters"""
        long_notes = "Equipment inspected thoroughly.\n" * 50 + "Pressure: 100 PSI\nTemp: 72°F"
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': long_notes,
            'result': 'Pass'
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['condition_notes'] == long_notes

    # RESULT VARIATIONS (2 tests)
    def test_result_none(self, test_db_with_dependencies):
        """Variation: result is None (optional field)"""
        payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Equipment in good condition',
            'result': None
        }
        
        response = client.post("/inspections/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['result'] is None

    def test_result_various_statuses(self, test_db_with_dependencies):
        """Variation: result with different status values"""
        result_statuses = ['Pass', 'Fail', 'Needs Repair', 'Retired']
        
        for i, result_status in enumerate(result_statuses):
            payload = {
                'gear_id': 1,
                'inspection_date': '2025-11-20',
                'inspector_id': 1,
                'inspection_type': 'Annual',
                'condition_notes': 'Equipment in good condition',
                'result': result_status
            }
            
            response = client.post("/inspections/", json=payload)
            
            assert response.status_code == 200
            data = response.json()
            assert data['result'] == result_status


class TestInspectionGetEndpoint:
    """Base Choice Coverage tests for GET /inspections endpoint"""

    def test_get_empty_database(self, test_db):
        """Database state: No inspections exist (empty list)"""
        response = client.get("/inspections/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 0

    def test_get_single_inspection(self, test_db_with_dependencies):
        """Database state: Single inspection exists"""
        # Create an inspection
        create_payload = {
            'gear_id': 1,
            'inspection_date': '2025-11-20',
            'inspector_id': 1,
            'inspection_type': 'Annual',
            'condition_notes': 'Good condition',
            'result': 'Pass'
        }
        client.post("/inspections/", json=create_payload)
        
        # Get all inspections
        response = client.get("/inspections/")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert 'id' in data[0]
        assert data[0]['gear_id'] == 1

    def test_get_multiple_inspections(self, test_db_with_dependencies):
        """Database state: Multiple inspections exist"""
        inspections = [
            {'gear_id': 1, 'inspection_date': '2025-11-20', 'inspector_id': 1, 'result': 'Pass'},
            {'gear_id': 1, 'inspection_date': '2025-10-15', 'inspector_id': 1, 'result': 'Pass'},
            {'gear_id': 1, 'inspection_date': '2025-09-10', 'inspector_id': 1, 'result': 'Fail'}
        ]
        
        for insp in inspections:
            client.post("/inspections/", json=insp)
        
        response = client.get("/inspections/")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 3
        assert all('id' in insp for insp in data)

    def test_get_inspections_with_null_fields(self, test_db_with_dependencies):
        """Database state: Inspections with optional fields as None"""
        payload = {
            'gear_id': 1,
            'inspection_date': None,
            'inspector_id': None,
            'inspection_type': None,
            'condition_notes': None,
            'result': None
        }
        client.post("/inspections/", json=payload)
        
        response = client.get("/inspections/")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]['gear_id'] == 1
        assert data[0]['inspection_date'] is None
        assert data[0]['inspector_id'] is None
        assert data[0]['inspection_type'] is None
        assert data[0]['condition_notes'] is None
        assert data[0]['result'] is None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
