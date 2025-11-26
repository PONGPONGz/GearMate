#!/bin/bash

# GearMate Automated Test Runner
# This script runs integration tests similar to Selenium for web

echo "======================================"
echo "GearMate Automated Integration Tests"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✓ Flutter detected: $(flutter --version | head -n 1)"
echo ""

# Navigate to client directory (parent of integration_test)
cd "$(dirname "$0")/.." || exit

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Are you in the right directory?"
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get
echo ""

# Check for connected devices/emulators
echo "🔍 Checking for available devices..."
devices=$(flutter devices)
echo "$devices"
echo ""

if echo "$devices" | grep -q "No devices detected"; then
    echo "❌ No devices or emulators found!"
    echo ""
    echo "Please start a device using one of these options:"
    echo "  1. Start Android emulator: flutter emulators --launch <emulator_id>"
    echo "  2. Open iOS simulator (macOS): open -a Simulator"
    echo "  3. Connect a physical device via USB"
    echo ""
    echo "To see available emulators: flutter emulators"
    exit 1
fi

echo "======================================"
echo "Running Integration Tests"
echo "======================================"
echo ""

# Run the integration tests
# Test files are in integration_test folder (Flutter standard)
TEST_FILE="integration_test/sorting_gear_test.dart"

if [ ! -f "$TEST_FILE" ]; then
    echo "❌ Test file not found: $TEST_FILE"
    exit 1
fi

echo "Running: $TEST_FILE"
echo ""

# Run the test
flutter test "$TEST_FILE"

TEST_EXIT_CODE=$?

echo ""
echo "======================================"
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ All tests PASSED!"
else
    echo "❌ Some tests FAILED"
fi
echo "======================================"

exit $TEST_EXIT_CODE
