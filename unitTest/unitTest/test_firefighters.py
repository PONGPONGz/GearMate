"""
Firefighters Router Tests
Tests for /firefighters endpoints using Base Choice Coverage ISP

Testing Strategy:
- Base Choice Input Space Partitioning (ISP)
- 1 Base test with typical/valid values
- Variations testing one parameter change at a time
- Focuses on realistic failure scenarios
- Uses FastAPI TestClient for real HTTP requests

Total Test Cases: 16 (1 base + 15 variations)
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
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_firefighters.db"
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
    """Create fresh database with department and station for FK tests"""
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
    
    db.close()
    yield
    Base.metadata.drop_all(bind=engine)


class TestFirefighterPostEndpoint:
    """Base Choice Coverage tests for POST /firefighters endpoint"""

    # BASE TEST: All valid typical values
    def test_base_all_valid_values(self, test_db_with_dependencies):
        """Base test: Valid firefighter with all fields populated with typical values"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        assert response.status_code == 200
        data = response.json()

    # NAME VARIATIONS (4 tests)
    def test_name_empty_string(self, test_db_with_dependencies):
        """Variation: name is empty string (should fail validation)"""
        payload = {
            'name': '',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        # Empty string should fail validation
        assert response.status_code == 422

    def test_name_with_special_characters(self, test_db_with_dependencies):
        """Variation: name contains special characters (apostrophe, hyphen)"""
        payload = {
            'name': "O'Brien-Smith",
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['name'] == "O'Brien-Smith"

    def test_name_null(self, test_db_with_dependencies):
        """Variation: name is None (should fail as required field)"""
        payload = {
            'name': None,
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        # None for required field should fail validation
        assert response.status_code == 422

    # RANKS VARIATIONS (1 test)
    def test_ranks_none(self, test_db_with_dependencies):
        """Variation: ranks is None (optional field)"""
        payload = {
            'name': 'John Doe',
            'ranks': None,
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['ranks'] is None

    # EMAIL VARIATIONS (2 tests)
    def test_email_none(self, test_db_with_dependencies):
        """Variation: email is None (optional field)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': None,
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['email'] is None

    # PHONE VARIATIONS
    def test_phone_none(self, test_db_with_dependencies):
        """Variation: phone is None (optional field)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': None,
            'station_id': 1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['phone'] is None

    # STATION_ID VARIATIONS (3 tests)
    def test_station_id_none(self, test_db_with_dependencies):
        """Variation: station_id is None (optional field)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': None,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['station_id'] is None

    def test_station_id_non_existent(self, test_db_with_dependencies):
        """Variation: station_id references non-existent station (FK violation)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 9999,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        # Foreign key violation should result in 400 error
        assert response.status_code == 400

    def test_station_id_negative(self, test_db_with_dependencies):
        """Variation: station_id is negative (invalid value)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': -1,
            'department_id': 1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        # Negative ID should cause FK violation or other error
        assert response.status_code in [400, 422]

    # DEPARTMENT_ID VARIATIONS (3 tests)
    def test_department_id_none(self, test_db_with_dependencies):
        """Variation: department_id is None (optional field)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': None
        }
        
        response = client.post("/firefighters/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['department_id'] is None

    def test_department_id_non_existent(self, test_db_with_dependencies):
        """Variation: department_id references non-existent department (FK violation)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 9999
        }
        
        response = client.post("/firefighters/", json=payload)
        
        # Foreign key violation should result in 500 or 400 error
        assert response.status_code == 400

    def test_department_id_negative(self, test_db_with_dependencies):
        """Variation: department_id is negative (invalid value)"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john.doe@firestation.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': -1
        }
        
        response = client.post("/firefighters/", json=payload)
        
        # Negative ID should cause FK violation or other error
        assert response.status_code in [400, 422]


class TestFirefighterGetEndpoint:
    """Base Choice Coverage tests for GET /firefighters endpoint"""

    def test_get_empty_database(self, test_db):
        """Database state: No firefighters exist (empty list)"""
        response = client.get("/firefighters/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 0

    def test_get_single_firefighter(self, test_db_with_dependencies):
        """Database state: Single firefighter exists"""
        # Create a firefighter
        create_payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john@fire.com',
            'phone': '555-1234',
            'station_id': 1,
            'department_id': 1
        }
        client.post("/firefighters/", json=create_payload)
        
        # Get all firefighters
        response = client.get("/firefighters/")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert 'id' in data[0]

    def test_get_multiple_firefighters(self, test_db_with_dependencies):
        """Database state: Multiple firefighters exist"""
        firefighters = [
            {'name': 'John Doe', 'ranks': 'Captain', 'station_id': 1, 'department_id': 1},
            {'name': 'Jane Smith', 'ranks': 'Lieutenant', 'station_id': 1, 'department_id': 1},
            {'name': 'Bob Johnson', 'ranks': 'Firefighter', 'station_id': 1, 'department_id': 1}
        ]
        
        for ff in firefighters:
            client.post("/firefighters/", json=ff)
        
        response = client.get("/firefighters/")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 3
        assert all('id' in ff for ff in data)
        
    def test_get_firefighters_with_null_fields(self, test_db):
        """Database state: Firefighters with optional fields as None"""
        payload = {
            'name': 'Minimal Firefighter',
            'ranks': None,
            'email': None,
            'phone': None,
            'station_id': None,
            'department_id': None
        }
        client.post("/firefighters/", json=payload)
        
        response = client.get("/firefighters/")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]['name'] == 'Minimal Firefighter'
        assert data[0]['ranks'] is None
        assert data[0]['email'] is None
        assert data[0]['phone'] is None
        assert data[0]['station_id'] is None
        assert data[0]['department_id'] is None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
