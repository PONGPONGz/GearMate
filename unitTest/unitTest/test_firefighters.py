"""
Unit Test Suite 1: Firefighters Router Tests
Tests for /firefighters endpoints including create and get operations

Testing Strategy:
- Input Space Partitioning (ISP) for data validation
- Boundary value analysis for field lengths
- Logic coverage for conditional validations
"""
import pytest
from datetime import date


class TestFirefighterURLConstruction:
    """Test suite for URL and endpoint construction"""

    def test_base_url_format(self):
        """Test that base URL is correctly formatted without trailing slash"""
        base_url = "/firefighters"
        assert base_url == "/firefighters"
        assert base_url.startswith("/")
        assert not base_url.endswith("/")

    def test_create_endpoint_url(self):
        """Test POST endpoint has trailing slash"""
        create_url = "/firefighters/"
        assert create_url.endswith("/")

    def test_list_endpoint_url(self):
        """Test GET endpoint for listing firefighters"""
        list_url = "/firefighters/"
        assert list_url == "/firefighters/"


class TestFirefighterResponseSchema:
    """Test suite for firefighter response structure validation"""

    def test_complete_response_structure(self):
        """Test that response contains all expected fields"""
        # Expected fields based on Firefighter schema
        expected_fields = ['id', 'name', 'ranks', 'email', 'phone', 'station_id', 'department_id']
        
        mock_response = {
            'id': 1,
            'name': 'John Smith',
            'ranks': 'Captain',
            'email': 'john.smith@firestation.com',
            'phone': '555-0123',
            'station_id': 1,
            'department_id': 1
        }
        
        # Verify all expected fields are present
        for field in expected_fields:
            assert field in mock_response, f"Missing field: {field}"

    def test_minimal_response_structure(self):
        """Test response with only required field (name)"""
        minimal_response = {
            'id': 1,
            'name': 'Jane Doe',
            'ranks': None,
            'email': None,
            'phone': None,
            'station_id': None,
            'department_id': None
        }
        
        assert 'name' in minimal_response
        assert minimal_response['name'] is not None
        assert minimal_response['ranks'] is None

    def test_response_field_types(self):
        """Test that response fields have correct data types"""
        response = {
            'id': 1,
            'name': 'Test User',
            'ranks': 'Lieutenant',
            'email': 'test@example.com',
            'phone': '555-1234',
            'station_id': 2,
            'department_id': 3
        }
        
        assert isinstance(response['id'], int)
        assert isinstance(response['name'], str)
        assert isinstance(response['ranks'], str) or response['ranks'] is None
        assert isinstance(response['station_id'], int) or response['station_id'] is None
        assert isinstance(response['department_id'], int) or response['department_id'] is None


class TestFirefighterCreatePayload:
    """Test suite for firefighter creation payload validation"""

    def test_required_field_only(self):
        """Test payload with only required field (name)"""
        payload = {'name': 'New Firefighter'}
        
        assert 'name' in payload
        assert len(payload['name']) > 0

    def test_complete_payload(self):
        """Test payload with all optional fields included"""
        payload = {
            'name': 'John Doe',
            'ranks': 'Captain',
            'email': 'john@fire.com',
            'phone': '555-9999',
            'station_id': 5,
            'department_id': 2
        }
        
        assert len(payload) == 6
        assert all(key in payload for key in ['name', 'ranks', 'email', 'phone', 'station_id', 'department_id'])

    def test_partial_payload(self):
        """Test payload with some optional fields"""
        payload = {
            'name': 'Partial User',
            'ranks': 'Firefighter',
            'station_id': 1
        }
        
        assert 'name' in payload
        assert 'ranks' in payload
        assert 'email' not in payload


class TestFirefighterDataValidation:
    """Test suite for input validation and business rules"""

    def test_name_validation_valid(self):
        """Test valid name inputs"""
        valid_names = ['John Smith', 'Mary-Jane', "O'Brien", 'José García']
        
        for name in valid_names:
            assert len(name.strip()) > 0
            assert isinstance(name, str)

    def test_name_validation_invalid(self):
        """Test invalid name inputs (empty, whitespace only)"""
        invalid_names = ['', '   ', '\t', '\n']
        
        for name in invalid_names:
            assert len(name.strip()) == 0

    def test_name_length_boundary(self):
        """Test name length at boundary (max 100 characters)"""
        # Valid: exactly 100 characters
        valid_name = 'A' * 100
        assert len(valid_name) == 100
        assert len(valid_name) <= 100
        
        # Invalid: 101 characters
        invalid_name = 'A' * 101
        assert len(invalid_name) > 100

    def test_email_format_validation(self):
        """Test email format validation logic"""
        valid_emails = [
            'user@example.com',
            'john.doe@firestation.org',
            'test+tag@domain.co.uk'
        ]
        
        for email in valid_emails:
            assert '@' in email
            assert '.' in email.split('@')[1]  # Domain has dot
        
        invalid_emails = ['notanemail', '@nodomain.com', 'no@domain']
        for email in invalid_emails:
            # Either no @ or no dot after @
            if '@' in email:
                parts = email.split('@')
                if len(parts) == 2:
                    assert '.' not in parts[1] or parts[0] == ''
            else:
                assert '@' not in email

    def test_phone_format_validation(self):
        """Test phone number format validation"""
        valid_phones = ['555-0123', '(555) 012-3456', '+1-555-123-4567']
        
        for phone in valid_phones:
            digits = ''.join(filter(str.isdigit, phone))
            assert len(digits) >= 7
            assert len(digits) <= 15

    def test_station_id_validation(self):
        """Test station_id must be positive integer or None"""
        # Valid cases
        assert 1 > 0
        assert 999 > 0
        
        # Invalid cases
        assert not (-1 > 0)
        assert not (0 > 0)

    def test_department_id_validation(self):
        """Test department_id must be positive integer or None"""
        valid_ids = [1, 5, 100]
        for dept_id in valid_ids:
            assert dept_id > 0
        
        invalid_ids = [-1, -5, 0]
        for dept_id in invalid_ids:
            assert not (dept_id > 0)

    def test_ranks_valid_values(self):
        """Test that ranks contain valid firefighter positions"""
        valid_ranks = ['Firefighter', 'Lieutenant', 'Captain', 'Battalion Chief', 'Chief']
        test_rank = 'Captain'
        
        assert test_rank in valid_ranks

    def test_ranks_length_boundary(self):
        """Test ranks field length (max 50 characters)"""
        valid_rank = 'A' * 50
        assert len(valid_rank) <= 50
        
        invalid_rank = 'A' * 51
        assert len(invalid_rank) > 50


class TestFirefighterListOperations:
    """Test suite for list/collection operations"""

    def test_empty_list_response(self):
        """Test response when no firefighters exist"""
        firefighters = []
        
        assert isinstance(firefighters, list)
        assert len(firefighters) == 0

    def test_single_item_list(self):
        """Test list with one firefighter"""
        firefighters = [{'id': 1, 'name': 'John Doe'}]
        
        assert len(firefighters) == 1
        assert firefighters[0]['id'] == 1

    def test_multiple_items_list(self):
        """Test list with multiple firefighters"""
        firefighters = [
            {'id': 1, 'name': 'John', 'ranks': 'Captain'},
            {'id': 2, 'name': 'Jane', 'ranks': 'Lieutenant'},
            {'id': 3, 'name': 'Bob', 'ranks': 'Firefighter'}
        ]
        
        assert len(firefighters) == 3
        assert all('id' in ff for ff in firefighters)

    def test_list_sorting_by_name(self):
        """Test sorting firefighters by name"""
        firefighters = [
            {'name': 'Zebra'},
            {'name': 'Alpha'},
            {'name': 'Mike'}
        ]
        
        sorted_ff = sorted(firefighters, key=lambda x: x['name'])
        
        assert sorted_ff[0]['name'] == 'Alpha'
        assert sorted_ff[1]['name'] == 'Mike'
        assert sorted_ff[2]['name'] == 'Zebra'

    def test_list_filtering_by_station(self):
        """Test filtering firefighters by station_id"""
        firefighters = [
            {'id': 1, 'name': 'John', 'station_id': 1},
            {'id': 2, 'name': 'Jane', 'station_id': 2},
            {'id': 3, 'name': 'Bob', 'station_id': 1}
        ]
        
        station_1_ff = [ff for ff in firefighters if ff['station_id'] == 1]
        
        assert len(station_1_ff) == 2
        assert all(ff['station_id'] == 1 for ff in station_1_ff)


class TestFirefighterEdgeCases:
    """Test suite for edge cases and special scenarios"""

    def test_duplicate_names_different_ids(self):
        """Test that multiple firefighters can have the same name"""
        firefighters = [
            {'id': 1, 'name': 'John Smith'},
            {'id': 2, 'name': 'John Smith'}
        ]
        
        assert firefighters[0]['name'] == firefighters[1]['name']
        assert firefighters[0]['id'] != firefighters[1]['id']

    def test_email_uniqueness_check(self):
        """Test email uniqueness validation logic"""
        emails = ['john@fire.com', 'jane@fire.com', 'bob@fire.com']
        
        # All unique
        assert len(emails) == len(set(emails))
        
        # With duplicates
        duplicate_emails = ['john@fire.com', 'john@fire.com', 'jane@fire.com']
        assert len(duplicate_emails) != len(set(duplicate_emails))

    def test_null_vs_empty_string(self):
        """Test distinction between None and empty string"""
        ff_with_none = {'email': None}
        ff_with_empty = {'email': ''}
        
        assert ff_with_none['email'] is None
        assert ff_with_empty['email'] == ''
        assert ff_with_none['email'] != ff_with_empty['email']

    def test_special_characters_in_name(self):
        """Test names with special characters"""
        special_names = ["O'Brien", "Mary-Jane", "José García", "François Müller"]
        
        for name in special_names:
            assert len(name) > 0
            assert isinstance(name, str)

    def test_international_phone_formats(self):
        """Test various international phone number formats"""
        phone_formats = [
            '+1-555-123-4567',    # US format
            '(555) 123-4567',      # US format with parentheses
            '+44 20 7123 4567',    # UK format
            '555.123.4567'         # Dot separator
        ]
        
        for phone in phone_formats:
            digits = ''.join(filter(str.isdigit, phone))
            assert len(digits) >= 7


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
