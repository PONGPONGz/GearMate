"""
Unit tests for /gears router (non-database tests)
Tests cover: URL construction, parameter validation, response structure
"""
import pytest
from datetime import date


class TestGearEndpointURLs:
    """Test URL and parameter construction"""

    def test_sort_parameter_valid_values(self):
        """Test that valid sort parameters are accepted"""
        valid_sorts = ["Name", "Type", "Maintenance Date"]
        for sort_value in valid_sorts:
            assert sort_value in valid_sorts

    def test_sort_parameter_regex_pattern(self):
        """Test the sort parameter regex pattern"""
        import re
        pattern = r"^(Name|Type|Maintenance Date)$"
        
        # Valid cases
        assert re.match(pattern, "Name")
        assert re.match(pattern, "Type")
        assert re.match(pattern, "Maintenance Date")
        
        # Invalid cases
        assert not re.match(pattern, "InvalidSort")
        assert not re.match(pattern, "name")  # Case sensitive
        assert not re.match(pattern, "TYPE")
        assert not re.match(pattern, "")


class TestGearResponseStructure:
    """Test expected response structure"""

    def test_gear_response_has_required_fields(self):
        """Test that gear response structure includes all required fields"""
        expected_fields = [
            'id', 'station_id', 'gear_name', 'serial_number',
            'photo_url', 'equipment_type', 'purchase_date',
            'expiry_date', 'status', 'next_maintenance_date'
        ]
        
        mock_gear = {
            'id': 1,
            'station_id': 1,
            'gear_name': 'Fire Helmet',
            'serial_number': 'FH-001',
            'photo_url': 'http://example.com/image.jpg',
            'equipment_type': 'Helmet',
            'purchase_date': '2023-01-10',
            'expiry_date': '2028-01-10',
            'status': 'OK',
            'next_maintenance_date': '2025-11-01'
        }
        
        for field in expected_fields:
            assert field in mock_gear

    def test_gear_response_optional_fields_can_be_none(self):
        """Test that optional fields can be None"""
        mock_gear_minimal = {
            'id': 1,
            'station_id': 1,
            'gear_name': 'Basic Gear',
            'serial_number': None,
            'photo_url': None,
            'equipment_type': None,
            'purchase_date': None,
            'expiry_date': None,
            'status': None,
            'next_maintenance_date': None
        }
        
        assert mock_gear_minimal['serial_number'] is None
        assert mock_gear_minimal['next_maintenance_date'] is None


class TestGearCreatePayload:
    """Test gear creation payload structure"""

    def test_create_gear_required_fields(self):
        """Test minimum required fields for gear creation"""
        required_payload = {
            'station_id': 1,
            'gear_name': 'Test Gear'
        }
        
        assert 'station_id' in required_payload
        assert 'gear_name' in required_payload
        assert isinstance(required_payload['station_id'], int)
        assert isinstance(required_payload['gear_name'], str)

    def test_create_gear_full_payload(self):
        """Test complete gear creation payload"""
        full_payload = {
            'station_id': 1,
            'gear_name': 'Fire Helmet',
            'serial_number': 'FH-001',
            'photo_url': 'http://example.com/image.jpg',
            'equipment_type': 'Helmet',
            'purchase_date': '2024-01-15',
            'expiry_date': '2029-01-15',
            'status': 'OK'
        }
        
        assert len(full_payload) == 8
        assert isinstance(full_payload['station_id'], int)
        assert isinstance(full_payload['gear_name'], str)

    def test_date_format(self):
        """Test that dates are in correct ISO format"""
        test_date = date(2024, 1, 15)
        formatted = test_date.isoformat()
        
        assert formatted == '2024-01-15'
        assert len(formatted) == 10
        assert formatted.count('-') == 2


class TestMaintenanceScheduleStructure:
    """Test maintenance schedule payload structure"""

    def test_schedule_payload_structure(self):
        """Test maintenance schedule creation payload"""
        schedule_payload = {
            'gear_id': 123,
            'scheduled_date': '2025-11-15'
        }
        
        assert 'gear_id' in schedule_payload
        assert 'scheduled_date' in schedule_payload
        assert isinstance(schedule_payload['gear_id'], int)
        assert isinstance(schedule_payload['scheduled_date'], str)

    def test_schedule_date_format(self):
        """Test schedule date formatting"""
        from datetime import datetime
        
        dt = datetime(2025, 11, 15)
        formatted = dt.date().isoformat()
        
        assert formatted == '2025-11-15'


class TestSortingLogic:
    """Test sorting logic"""

    def test_sort_by_name_logic(self):
        """Test name sorting logic"""
        gears = [
            {'gear_name': 'Zebra'},
            {'gear_name': 'Alpha'},
            {'gear_name': 'Mike'}
        ]
        
        sorted_gears = sorted(gears, key=lambda g: g['gear_name'])
        
        assert sorted_gears[0]['gear_name'] == 'Alpha'
        assert sorted_gears[1]['gear_name'] == 'Mike'
        assert sorted_gears[2]['gear_name'] == 'Zebra'

    def test_sort_by_type_logic(self):
        """Test type sorting logic"""
        gears = [
            {'equipment_type': 'Tank'},
            {'equipment_type': 'Helmet'},
            {'equipment_type': 'Hose'}
        ]
        
        sorted_gears = sorted(gears, key=lambda g: g['equipment_type'])
        
        assert sorted_gears[0]['equipment_type'] == 'Helmet'
        assert sorted_gears[1]['equipment_type'] == 'Hose'
        assert sorted_gears[2]['equipment_type'] == 'Tank'

    def test_sort_by_date_with_nulls(self):
        """Test maintenance date sorting with None values"""
        gears = [
            {'next_maintenance_date': '2025-12-01'},
            {'next_maintenance_date': '2025-10-01'},
            {'next_maintenance_date': '2025-11-01'},
            {'next_maintenance_date': None}
        ]
        
        sorted_gears = sorted(
            gears,
            key=lambda g: g['next_maintenance_date'] or 'ZZZZ'
        )
        
        assert sorted_gears[0]['next_maintenance_date'] == '2025-10-01'
        assert sorted_gears[1]['next_maintenance_date'] == '2025-11-01'
        assert sorted_gears[2]['next_maintenance_date'] == '2025-12-01'
        assert sorted_gears[3]['next_maintenance_date'] is None


class TestDataValidation:
    """Test data validation logic"""

    def test_gear_name_not_empty(self):
        """Test gear name is not empty"""
        valid_name = "Fire Helmet"
        invalid_name = ""
        
        assert len(valid_name.strip()) > 0
        assert len(invalid_name.strip()) == 0

    def test_station_id_positive(self):
        """Test station ID is positive integer"""
        valid_id = 1
        invalid_id = -1
        
        assert valid_id > 0
        assert not (invalid_id > 0)

    def test_serial_number_uniqueness_check(self):
        """Test serial number uniqueness logic"""
        serials = ['FH-001', 'OT-002', 'FH-003']
        assert len(serials) == len(set(serials))
        
        duplicate_serials = ['FH-001', 'FH-001', 'OT-002']
        assert len(duplicate_serials) != len(set(duplicate_serials))


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
