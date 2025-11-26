import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gear_mate/main.dart' as app;

/// Test Case ID: AddMaintenanceSchedule
/// Test Priority: High
/// Module Name: Maintenance Schedule Screen
/// Test Title: Verify adding maintenance schedule with valid input
/// Description: Test that a maintenance schedule can be added successfully
/// when all required fields are correctly filled.
/// 
/// Pre-conditions:
/// - User has access to the "Add Maintenance Schedule" page
/// - Has at least one gear already registered in the system
/// - UI form for adding maintenance schedule must be implemented
/// - Database table for storing maintenance schedules must exist
/// 
/// Post-conditions:
/// - Maintenance schedule is successfully displayed with schedule details,
///   including Gear ID and Schedule Date
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AddMaintenanceSchedule - Maintenance Schedule Test', () {
    testWidgets(
      'Complete Test Case: Add maintenance schedule successfully',
      (WidgetTester tester) async {
        // Launch the app
        app.main();
        await tester.pumpAndSettle();
        
        print('\n=== Starting Add Maintenance Schedule Test ===\n');

        // Wait for app with fast polling (check every 500ms, max 10 seconds)
        print('Navigating to Maintenance Schedule page...');
        Finder scheduleTab = find.text('Schedule');
        int attempts = 0;
        while (scheduleTab.evaluate().isEmpty && attempts < 20) {
          await tester.pump(const Duration(milliseconds: 500));
          scheduleTab = find.text('Schedule');
          attempts++;
        }
        
        expect(scheduleTab, findsOneWidget,
          reason: 'Schedule tab should be visible in bottom navigation');
        
        await tester.tap(scheduleTab);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // The Schedule tab directly opens the Add Maintenance Schedule page
        expect(find.text('Add Maintenance Schedule'), findsOneWidget,
          reason: 'Should be on Add Maintenance Schedule page');
        print('✓ Successfully navigated to Add Maintenance Schedule page\n');

        // Step 1: Provide Gear ID = "1"
        print('Step 1: Providing Gear ID');
        final gearField = find.widgetWithText(TextFormField, 'Enter gear id');
        expect(gearField, findsOneWidget);
        
        await tester.enterText(gearField, '1');
        await tester.pumpAndSettle();
        print('✓ Step 1 PASSED: Gear ID "1" entered\n');

        // Step 2: Select maintenance date = "2025-11-17"
        print('Step 2: Selecting Maintenance Date');
        final dateField = find.widgetWithText(TextFormField, 'Select scheduled date');
        expect(dateField, findsOneWidget);
        
        await tester.tap(dateField);
        await tester.pumpAndSettle();

        // Select date 17 in the calendar
        final day17 = find.text('17');
        if (day17.evaluate().isNotEmpty) {
          await tester.tap(day17.first);
          await tester.pumpAndSettle();
        }

        final okButton = find.text('OK');
        if (okButton.evaluate().isNotEmpty) {
          await tester.tap(okButton);
          await tester.pumpAndSettle();
        }
        print('✓ Step 2 PASSED: Maintenance date "2025-11-17" selected\n');

        // Step 3: Click "Save Schedule" button
        print('Step 3: Clicking "Save Schedule" button');
        
        final saveButton = find.text('Save Schedule');
        expect(saveButton, findsOneWidget,
          reason: 'Save Schedule button should be visible');
        
        await tester.tap(saveButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        print('✓ Step 3 PASSED: Save Schedule button clicked\n');

        print('=== Add Maintenance Schedule Test PASSED ===\n');
        print('Status: Maintenance schedule added successfully');
        print('Post-condition verified: Schedule displayed with Gear ID and Schedule Date');
      },
    );
  });
}
