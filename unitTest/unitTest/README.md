# Unit Test Suite

This directory contains unit tests for the GearMate API routers.

## Test Coverage

The unit tests are designed to meet the following requirements:
- **3 test suites** covering different API routers
- **Statement coverage**: ≥70% for all tested methods
- **Branch coverage**: ≥70% for all tested methods

## Test Suites

### 1. test_firefighters.py
Tests for `/firefighters` endpoints including:
- URL construction and validation
- Response schema validation
- Create payload validation
- Data validation (name, email, phone, ranks)
- List operations (sorting, filtering)
- Edge cases (duplicates, special characters)

**Testing Techniques Used:**
- Input Space Partitioning (ISP) for field validation
- Boundary value analysis for string lengths
- Logic coverage for conditional validations

### 2. test_inspections.py
Tests for `/inspections` endpoints including:
- URL construction
- Response schema validation
- Create payload validation
- Data validation (dates, gear_id, inspector_id, result)
- List operations (filtering, sorting)
- Edge cases (multiple inspections per gear, date handling)

**Testing Techniques Used:**
- Boundary value analysis for dates
- Logic coverage for result status validation
- Input Space Partitioning for optional fields

### 3. test_stations.py
Tests for `/stations` endpoints including:
- URL construction
- Response schema validation
- Create payload validation
- Data validation (name, location, department_id)
- List operations (sorting, filtering by department)
- Edge cases (multiple stations per department, location formatting)

**Testing Techniques Used:**
- Input Space Partitioning for location data
- Boundary value analysis for name lengths
- Logic coverage for department relationships

## Running the Tests

### Install Dependencies
```bash
cd api
pip install -r requirements-dev.txt
```

### Run All Unit Tests
```bash
pytest "unitTest/" -v
```

### Run Specific Test Suite
```bash
pytest "unitTest/test_firefighters.py" -v
pytest "unitTest/test_inspections.py" -v
pytest "unitTest/test_stations.py" -v
```

### Generate Coverage Report
```bash
pytest "unit test/" --cov=routers --cov-report=html --cov-report=term-missing --cov-branch
```

This will generate:
- Terminal output with coverage percentages
- HTML report in `htmlcov/` directory

### View HTML Coverage Report
```bash
open htmlcov/index.html  # macOS
```

## Test Structure

Each test file contains multiple test classes, each focusing on a specific aspect:

- **URL Construction Tests**: Validate endpoint URLs
- **Response Schema Tests**: Ensure response structure matches expected format
- **Create Payload Tests**: Validate request payload structure
- **Data Validation Tests**: Test business rules and validation logic
- **List Operations Tests**: Test filtering, sorting, and collection operations
- **Edge Cases Tests**: Test boundary conditions and special scenarios

## Coverage Requirements

According to project requirements:
- ✅ At least 3 unit test suites
- ✅ Each suite contains multiple test cases
- ✅ Brief description as comment above each test case
- ✅ Statement coverage ≥70%
- ✅ Branch coverage ≥70%

## Notes

- These are **pure unit tests** - no database required
- Tests use mock data and validation logic
- Focus on testing individual methods and functions
- Independent of system/integration tests
- Can run quickly and in isolation


## Notes For Updated test (Window env)
Enter venv environment
```bash
cd api
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cd ..

pytest unitTest/unitTest -v
pytest unitTest/unitTest -v --cov=. --cov-report=term-missing --cov-report=html:htmlcov
```