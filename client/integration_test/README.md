# GearMate Automated Integration Tests

This folder contains automated integration tests for the GearMate Flutter application. These tests are similar to Selenium for web applications - they run on actual devices/emulators and interact with the UI just like a real user would.

## Test Cases

### SortingGear_Hap
**Test Case ID:** SortingGear_Hap  
**Priority:** Low  
**Module:** Gear List Screen  
**Test Title:** Verify sorting gear list successfully  

**Description:** Ensure gear list is correctly sorted based on selected criteria.

**Pre-conditions:**
- User has access to the "Gear List" page
- Sorting menu must be implemented
- Gear list data must exist in the database
- Sorting rules must be defined

**Test Steps:**
1. **Step 1:** Select "Sort by Name" → Gear list sorted Alphabetically
2. **Step 2:** Select "Sort by Type" → Gear list sorted by gear type
3. **Step 3:** Select "Sort by Maintenance Date" → Gear list sorted earliest to latest date

**Post-conditions:**
- Gear list is displayed in sorted order
- No data is modified

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Device/Emulator** running:
   - Android emulator (recommended: API level 29+)
   - iOS simulator (requires macOS)
   - Physical device connected via USB
3. **API Server** running at `http://localhost:8000` (or appropriate endpoint)
4. **Test data** populated in the database

## Setup

1. Install dependencies:
```bash
cd /Users/jimmy/GearMate/client
flutter pub get
```

2. Ensure the API server is running:
```bash
cd /Users/jimmy/GearMate/api
python3 -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

3. Start an emulator or connect a device:
```bash
# List available devices/emulators
flutter devices

# Start an Android emulator
flutter emulators --launch <emulator_id>

# Or for iOS simulator (macOS only)
open -a Simulator
```

## Running Tests

### Run a specific test file
```bash
# Run the sorting gear test
flutter test integration_test/sorting_gear_test.dart
```

### Run all integration tests
```bash
flutter test integration_test/
```

### Run with visual output on device/emulator
This will show the test running on the actual device/emulator screen:

```bash
# For Android
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/sorting_gear_test.dart \
  -d <device_id>

# Or simply
flutter test integration_test/sorting_gear_test.dart --device-id=<device_id>
```

### Run on specific device
```bash
# List available devices
flutter devices

# Run on specific device
flutter test integration_test/sorting_gear_test.dart -d <device_id>

# Examples:
# flutter test integration_test/sorting_gear_test.dart -d emulator-5554
# flutter test integration_test/sorting_gear_test.dart -d chrome
```

## Test Output

The tests will provide detailed output including:
- Each test step being executed
- Pass/Fail status for each assertion
- Detailed error messages if any test fails
- Console logs with step confirmations

Example output:
```
Testing: Sort by Name
✓ Sort by Name - PASSED

Testing: Sort by Type
✓ Sort by Type - PASSED

Testing: Sort by Maintenance Date
✓ Sort by Maintenance Date - PASSED

=== Complete Sorting Test PASSED ===
Status: All sorting options working correctly
```

## Troubleshooting

### Issue: "No devices found"
**Solution:** Start an emulator or connect a physical device

### Issue: API connection errors
**Solution:** 
- Ensure API server is running on port 8000
- Check network connectivity
- For Android emulator, API should be accessible at `http://10.0.2.2:8000`
- For iOS simulator, use `http://localhost:8000`

### Issue: Test timeout
**Solution:**
- Increase timeout duration in test code
- Check if API is responding slowly
- Ensure device/emulator has sufficient resources

### Issue: Widget not found
**Solution:**
- Ensure the app is fully loaded before testing
- Add `await tester.pumpAndSettle()` to wait for animations
- Check if the widget key or text has changed in the UI

## Writing New Tests

To add new integration tests:

1. Create a new test file in `integration_test/` folder
2. Follow this structure:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gear_mate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Your Test Group', () {
    testWidgets('Your test description', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Your test steps here
      // Example: tap a button
      await tester.tap(find.text('Button Text'));
      await tester.pumpAndSettle();

      // Assertions
      expect(find.text('Expected Result'), findsOneWidget);
    });
  });
}
```

## Best Practices

1. **Wait for animations:** Always use `await tester.pumpAndSettle()` after interactions
2. **Add delays for API calls:** Use `await tester.pumpAndSettle(const Duration(seconds: 2))` when waiting for network requests
3. **Clear descriptions:** Write clear test descriptions matching the test case documentation
4. **Verify preconditions:** Check that required elements exist before interacting
5. **Assert postconditions:** Verify expected outcomes after actions
6. **Clean state:** Each test should be independent and not rely on previous test state

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Integration Tests
  run: |
    flutter pub get
    flutter test integration_test/
```

## References

- [Flutter Integration Testing Documentation](https://docs.flutter.dev/testing/integration-tests)
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
- [Integration Test Package](https://pub.dev/packages/integration_test)
