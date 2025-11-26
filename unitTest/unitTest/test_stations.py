"""
Stations Router Tests
Tests for /stations endpoints using Base Choice Coverage ISP

Testing Strategy:
- Base Choice Input Space Partitioning (ISP)
- 1 Base test with typical/valid values
- Variations testing one parameter change at a time
- Focuses on realistic failure scenarios
- Uses FastAPI TestClient for real HTTP requests

Total Test Cases: 14
- 10 POST tests (1 base + 9 variations)
- 4 GET tests (database state partitions)
Base Choice Coverage - Selected Characteristics:
1. name (required field)
   - Base: Valid name string 'Fire Station 1'
   - Variations: Empty string, Special characters, None

2. location (optional field)
   - Base: Valid address '123 Main St, City, State 12345'
   - Variations: None, Empty string, Long text

3. department_id (optional field, FK to department)
   - Base: Valid positive integer (1)
   - Variations: None, Non-existent FK, Negative

Base Choice Coverage - Selected Characteristics (GET /stations):

1. Empty Database
   - No stations exist
   - Expect empty list

2. Single Station
   - One station exists
   - Expect list containing the created station

3. Multiple Stations
   - Several stations exist
   - Expect list containing all stations with valid IDs

4. Stations With Null Optional Fields
   - Station exists with location and department_id set to None
   - Expect null values returned correctly
"""
import pytest
import models


class TestStationPostEndpoint:
    """Base Choice Coverage tests for POST /stations endpoint"""

    # BASE TEST: All valid typical values
    def test_base_all_valid_values(self, client, test_db_with_dependencies):
        """Base test: Valid station with all fields populated with typical values"""
        payload = {
            'name': 'Fire Station 1',
            'location': '123 Main St, City, State 12345',
            'department_id': 1
        }
        
        response = client.post("/stations/", json=payload)
        
        assert response.status_code == 200
        data = response.json()

    # NAME VARIATIONS (3 tests)
    def test_name_empty_string(self, client, test_db_with_dependencies):
        """Variation: name is empty string (should fail validation)"""
        payload = {
            'name': '',
            'location': '123 Main St, City, State 12345',
            'department_id': 1
        }
        
        response = client.post("/stations/", json=payload)
        
        # Empty string should fail validation
        assert response.status_code == 422

    def test_name_with_special_characters(self, client, test_db_with_dependencies):
        """Variation: name contains special characters"""
        payload = {
            'name': "Station #5 - O'Brien",
            'location': '123 Main St, City, State 12345',
            'department_id': 1
        }
        
        response = client.post("/stations/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['name'] == "Station #5 - O'Brien"

    def test_name_none(self, client, test_db_with_dependencies):
        """Variation: name is None (required field)"""
        payload = {
            'name': None,
            'location': '123 Main St, City, State 12345',
            'department_id': 1
        }
        
        response = client.post("/stations/", json=payload)
        
        # None for required field should fail validation
        assert response.status_code == 422

    # LOCATION VARIATIONS (3 tests)
    def test_location_none(self, client, test_db_with_dependencies):
        """Variation: location is None (optional field)"""
        payload = {
            'name': 'Fire Station 1',
            'location': None,
            'department_id': 1
        }
        
        response = client.post("/stations/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['location'] is None

    def test_location_empty_string(self, client, test_db_with_dependencies):
        """Variation: location is empty string"""
        payload = {
            'name': 'Fire Station 1',
            'location': '',
            'department_id': 1
        }
        
        response = client.post("/stations/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['location'] == ''

    def test_location_long_text(self, client, test_db_with_dependencies):
        """Variation: location with long text and special characters"""
        long_location = "Building 5, Floor 3\n" * 10 + "123 Main St., Apt. #100, City, ST 12345"
        payload = {
            'name': 'Fire Station 1',
            'location': long_location,
            'department_id': 1
        }
        
        response = client.post("/stations/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['location'] == long_location

    # DEPARTMENT_ID VARIATIONS (3 tests)
    def test_department_id_none(self, client, test_db_with_dependencies):
        """Variation: department_id is None (optional field)"""
        payload = {
            'name': 'Fire Station 1',
            'location': '123 Main St, City, State 12345',
            'department_id': None
        }
        
        response = client.post("/stations/", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        assert data['department_id'] is None

    def test_department_id_non_existent(self, client, test_db_with_dependencies):
        """Variation: department_id references non-existent department (FK violation)"""
        payload = {
            'name': 'Fire Station 1',
            'location': '123 Main St, City, State 12345',
            'department_id': 9999
        }
        
        response = client.post("/stations/", json=payload)
        
        # Foreign key violation should result in 400 error
        assert response.status_code == 400

    def test_department_id_negative(self, client, test_db_with_dependencies):
        """Variation: department_id is negative (invalid value)"""
        payload = {
            'name': 'Fire Station 1',
            'location': '123 Main St, City, State 12345',
            'department_id': -1
        }
        
        response = client.post("/stations/", json=payload)
        
        # Negative ID should cause FK violation or validation error
        assert response.status_code in [400, 422]


class TestStationGetEndpoint:
    """Base Choice Coverage tests for GET /stations endpoint"""

    def test_get_empty_database(self, client, db_session):
        """Database state: No stations exist (empty list)"""
        response = client.get("/stations/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 0

    def test_get_single_station(self, client, test_db_with_dependencies):
        """Database state: Single station exists"""
        # Create a station
        create_payload = {
            'name': 'Central Station',
            'location': '456 Oak Ave',
            'department_id': 1
        }
        client.post("/stations/", json=create_payload)
        
        # Get all stations
        response = client.get("/stations/")
        
        assert response.status_code == 200
        data = response.json()
        # test_db_with_dependencies creates 1 station already, so we expect 2
        assert len(data) == 2
        assert 'id' in data[0]

    def test_get_multiple_stations(self, client, test_db_with_dependencies):
        """Database state: Multiple stations exist"""
        stations = [
            {'name': 'Station Alpha', 'location': '100 North St', 'department_id': 1},
            {'name': 'Station Beta', 'location': '200 South St', 'department_id': 1},
            {'name': 'Station Gamma', 'location': '300 East St', 'department_id': 1}
        ]
        
        for station in stations:
            client.post("/stations/", json=station)
        
        response = client.get("/stations/")
        
        assert response.status_code == 200
        data = response.json()
        # test_db_with_dependencies creates 1 station already, so we expect 1 + 3 = 4
        assert len(data) == 4
        assert all('id' in station for station in data)

    def test_get_stations_with_null_fields(self, client, db_session):
        """Database state: Stations with optional fields as None"""
        payload = {
            'name': 'Minimal Station',
            'location': None,
            'department_id': None
        }
        client.post("/stations/", json=payload)
        
        response = client.get("/stations/")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]['name'] == 'Minimal Station'
        assert data[0]['location'] is None
        assert data[0]['department_id'] is None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])

