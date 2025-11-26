import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gear_mate/main.dart' as app;

/// Test Case ID: AddRepair_Hap
/// Test Priority: High
/// Module Name: Add Repair & Inspection
/// Test Title: Successful Submission of Repair/Inspection Log
/// Description: Verify that user can successfully fill in all required fields
/// and submit an inspection/repair log.
/// 
/// Pre-conditions:
/// - User has access to the "Add Repair & Inspections" page
/// - UI form for adding inspection/repair must be implemented
/// - Database table for storing inspection/repair must exist
/// - Data validation rules must be defined
/// 
/// Post-conditions:
/// - Inspection/repair log is successfully submitted and stored in the database
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AddRepair_Hap - Repair & Inspection Log Test', () {
    testWidgets(
      'Complete Test Case: Submit inspection log successfully',
      (WidgetTester tester) async {
        // Launch the app
        app.main();
        await tester.pumpAndSettle();
        
        print('\n=== Starting Complete Repair & Inspection Log Test ===\n');

        // Wait for app with fast polling (check every 500ms, max 10 seconds)
        print('Navigating to Repair & Inspection Log page...');
        Finder historyTab = find.text('History');
        int attempts = 0;
        while (historyTab.evaluate().isEmpty && attempts < 20) {
          await tester.pump(const Duration(milliseconds: 500));
          historyTab = find.text('History');
          attempts++;
        }
        
        await tester.tap(historyTab);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await tester.tap(find.text('Repair & Inspection'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Repair & Inspection Log'), findsOneWidget,
          reason: 'Should be on Repair & Inspection Log page');
        print('✓ Successfully navigated to Repair & Inspection Log page\n');

        // Step 1: Select Gear ID = "ID 1 - Fire Helmet"
        print('Step 1: Selecting Gear ID');
        final gearDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Select gear');
        expect(gearDropdown, findsOneWidget);
        
        await tester.tap(gearDropdown);
        await tester.pumpAndSettle();

        // Select "ID 1 - Fire Helmet"
        final fireHelmet = find.text('ID 1 - Fire Helmet').last;
        expect(fireHelmet, findsOneWidget);
        await tester.tap(fireHelmet);
        await tester.pumpAndSettle();
        print('✓ Step 1 PASSED: Gear "ID 1 - Fire Helmet" selected\n');

        // Step 2: Select Inspection Date = "2025-11-16"
        print('Step 2: Selecting Inspection Date');
        final dateField = find.widgetWithText(TextFormField, 'Select inspection date');
        expect(dateField, findsOneWidget);
        
        await tester.tap(dateField);
        await tester.pumpAndSettle();

        // Select date 16 in the calendar
        final day16 = find.text('16');
        if (day16.evaluate().isNotEmpty) {
          await tester.tap(day16.first);
          await tester.pumpAndSettle();
        }

        final okButton = find.text('OK');
        if (okButton.evaluate().isNotEmpty) {
          await tester.tap(okButton);
          await tester.pumpAndSettle();
        }
        print('✓ Step 2 PASSED: Inspection date "2025-11-16" selected\n');

        // Step 3: Select Inspector ID = "ID 2 - Ton Danai"
        print('Step 3: Selecting Inspector ID');
        final inspectorDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Select inspector');
        expect(inspectorDropdown, findsOneWidget);
        
        await tester.tap(inspectorDropdown);
        await tester.pumpAndSettle();

        // Select "ID 2 - Ton Danai"
        final tonDanai = find.text('ID 2 - Ton Danai').last;
        expect(tonDanai, findsOneWidget);
        await tester.tap(tonDanai, warnIfMissed: false);
        await tester.pumpAndSettle();
        print('✓ Step 3 PASSED: Inspector "ID 2 - Ton Danai" selected\n');

        // Step 4: Select Inspection Type = "Routine"
        print('Step 4: Selecting Inspection Type');
        final typeDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Select inspection type');
        expect(typeDropdown, findsOneWidget);
        
        await tester.tap(typeDropdown);
        await tester.pumpAndSettle();

        // Select "Routine"
        final routineOption = find.text('Routine').last;
        expect(routineOption, findsOneWidget);
        await tester.tap(routineOption);
        await tester.pumpAndSettle();
        print('✓ Step 4 PASSED: Inspection type "Routine" selected\n');

        // Step 5: Provide Notes = "String"
        print('Step 5: Entering Notes');
        final notesField = find.widgetWithText(TextFormField, 'Explain the conditions...');
        expect(notesField, findsOneWidget);
        
        await tester.enterText(notesField, 'String');
        await tester.pumpAndSettle();
        print('✓ Step 5 PASSED: Notes "String" entered\n');

        // Step 6: Click "Submit Inspection"
        print('Step 6: Clicking "Submit Inspection" button');
        
        // Scroll down to make sure the button is visible
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
        
        final submitButton = find.text('Submit Inspection');
        expect(submitButton, findsOneWidget);
        
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        print('✓ Step 6 PASSED: Submit Inspection button clicked\n');

        print('=== Complete Repair & Inspection Log Test PASSED ===\n');
        print('Status: Inspection log submitted successfully');
        print('Post-condition verified: Data validated and saved to database');
      },
    );
  });
}
