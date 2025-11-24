#!/bin/bash
# Script to run unit tests with coverage reporting

echo "======================================"
echo "Running Unit Tests with Coverage"
echo "======================================"
echo ""

# Run tests with coverage for the router files
python3 -m pytest "unit test/" \
    --cov=routers/firefighters \
    --cov=routers/inspections \
    --cov=routers/stations \
    --cov-report=html:htmlcov \
    --cov-report=term-missing \
    --cov-branch \
    -v

echo ""
echo "======================================"
echo "Coverage Report Generated"
echo "======================================"
echo ""
echo "View HTML report: open htmlcov/index.html"
echo ""
