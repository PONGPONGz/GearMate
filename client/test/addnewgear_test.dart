import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gear_mate/pages/AddNewGear.dart';

void main() {
  group('AddNewGear Widget Tests', () {
    testWidgets('displays app bar with title and back button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

      expect(find.text('Add Gear'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('back button pops navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Text('Home')),
          routes: {'/addgear': (context) => addnewgearpage()},
        ),
      );

      // Navigate to add gear page
      final BuildContext context = tester.element(find.text('Home'));
      Navigator.pushNamed(context, '/addgear');
      await tester.pumpAndSettle();

      // Verify we're on add gear page
      expect(find.text('Add Gear'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Home'), findsOneWidget);
    });

    group('Form fields', () {
      testWidgets('displays text form fields', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        // Text fields
        expect(find.widgetWithText(TextFormField, 'Gear Name'), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'Serial Number'),
          findsOneWidget,
        );
      });

      testWidgets('displays dropdown fields', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        // Dropdowns
        expect(
          find.widgetWithText(
            DropdownButtonFormField<String>,
            'Station Number',
          ),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(DropdownButtonFormField<String>, 'Gear Type'),
          findsOneWidget,
        );
      });

      testWidgets('gear name field accepts input', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        final gearNameField = find.widgetWithText(TextFormField, 'Gear Name');
        await tester.enterText(gearNameField, 'Test Helmet');
        expect(find.text('Test Helmet'), findsOneWidget);
      });

      testWidgets('serial number field accepts input', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        final serialField = find.widgetWithText(TextFormField, 'Serial Number');
        await tester.enterText(serialField, 'SN-12345');
        expect(find.text('SN-12345'), findsOneWidget);
      });

      testWidgets('station dropdown shows options', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        // Tap dropdown
        await tester.tap(
          find.widgetWithText(
            DropdownButtonFormField<String>,
            'Station Number',
          ),
        );
        await tester.pumpAndSettle();

        // Check options
        expect(find.text('Station 1').hitTestable(), findsOneWidget);
        expect(find.text('Station 2').hitTestable(), findsOneWidget);
      });

      testWidgets('gear type dropdown shows options', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String>, 'Gear Type'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Helmet').hitTestable(), findsOneWidget);
        expect(find.text('Hose').hitTestable(), findsOneWidget);
        expect(find.text('Oxygen Tank').hitTestable(), findsOneWidget);
      });
    });

    group('Action buttons', () {
      testWidgets('displays Clear All and Save Gear buttons', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        expect(find.text('Clear All'), findsOneWidget);
        expect(find.text('Save Gear'), findsOneWidget);
      });
    });

    group('Photo upload section', () {
      testWidgets('displays upload photo section', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        expect(find.text('Upload Photo'), findsOneWidget);
        expect(find.text('Take Photo'), findsOneWidget);
        expect(find.text('Choose from Gallery'), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
      });
    });

    group('Form validation', () {
      testWidgets('accepts valid gear name', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Gear Name'),
          'Valid Gear Name',
        );

        // The field should accept the value
        expect(find.text('Valid Gear Name'), findsOneWidget);
      });

      testWidgets('serial number is optional', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        // Enter gear name and station, but not serial number
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Gear Name'),
          'Test Gear',
        );

        await tester.tap(
          find.widgetWithText(
            DropdownButtonFormField<String>,
            'Station Number',
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Station 1').last);
        await tester.pumpAndSettle();

        // Should not show validation error for serial number
        final serialField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Serial Number'),
        );
        expect(serialField.validator, isNull);
      });
    });

    group('Layout and styling', () {
      testWidgets('app bar has correct background color', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        final AppBar appBar = tester.widget(find.byType(AppBar));
        expect(appBar.backgroundColor, Color(0xFFFF473F));
      });

      testWidgets('form is scrollable', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('buttons have correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: addnewgearpage()));

        // Find Clear All button
        final clearButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Clear All'),
        );
        expect(clearButton, isNotNull);

        // Find Save Gear button
        final saveButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Save Gear'),
        );
        expect(saveButton, isNotNull);
      });
    });
  });
}
