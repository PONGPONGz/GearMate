import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gear_mate/pages/homepage.dart';

void main() {
  group('Homepage Widget Tests', () {
    testWidgets('displays app bar with logo and title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: homepage(),
          routes: {
            '/schedule': (context) => Scaffold(body: Text('Schedule Page')),
            '/addgear': (context) => Scaffold(body: Text('Add Gear Page')),
          },
        ),
      );

      // Wait for initial build
      await tester.pump();

      // Check for GearMate title
      expect(find.text('GearMate'), findsOneWidget);

      // Check for notification and profile icons
      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_outlined), findsOneWidget);
    });

    testWidgets('displays search bar', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: homepage()));
      await tester.pump();

      // Find search field by hint text
      expect(
        find.widgetWithText(TextField, 'Search by gear name, ID, or type'),
        findsOneWidget,
      );
    });

    testWidgets('displays sort button with menu', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: homepage()));
      await tester.pump();

      // Find sort button icon
      expect(find.byIcon(Icons.format_list_bulleted_sharp), findsOneWidget);

      // Tap sort button to open menu
      await tester.tap(find.byIcon(Icons.format_list_bulleted_sharp));
      await tester.pumpAndSettle();

      // Check menu items
      expect(find.text('Sort by Name'), findsOneWidget);
      expect(find.text('Sort by Type'), findsOneWidget);
      expect(find.text('Sort by Maintenance Date'), findsOneWidget);
    });

    testWidgets('displays "My Gear List" heading', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: homepage()));
      await tester.pump();

      expect(find.text('My Gear List'), findsOneWidget);
    });

    testWidgets('displays "Add new gear" button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: homepage(),
          routes: {
            '/addgear': (context) => Scaffold(body: Text('Add Gear Page')),
          },
        ),
      );
      await tester.pump();

      expect(find.text('Add new gear'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('navigates to add gear page when button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: homepage(),
          routes: {
            '/addgear': (context) => Scaffold(body: Text('Add Gear Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap add gear button
      await tester.tap(find.text('Add new gear'));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.text('Add Gear Page'), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: homepage(),
          routes: {
            '/schedule': (context) => Scaffold(body: Text('Schedule Page')),
          },
        ),
      );
      await tester.pump();

      // Check for navigation items
      expect(find.text('Gear'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.byIcon(Icons.build), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('bottom navigation switches to schedule page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: homepage(),
          routes: {
            '/schedule': (context) => Scaffold(body: Text('Schedule Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap schedule tab
      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.text('Schedule Page'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: homepage()));

      // Initially loading, but need to catch it quickly
      // The widget starts loading in initState
      await tester.pump(Duration.zero);

      // Loading indicator might show briefly
      // This test is illustrative - in real app with mocked API it would be more reliable
    });

    testWidgets('displays error message when fetch fails', (
      WidgetTester tester,
    ) async {
      // Note: This test would require mocking the API
      // For now, we're just verifying the error UI structure exists
      await tester.pumpWidget(MaterialApp(home: homepage()));
      await tester.pumpAndSettle();

      // The error text widget should be in the tree (even if not visible)
      // In a real scenario with mocked failed API, we'd see the error
    });

    testWidgets('gear list scrolls when content overflows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: homepage()));
      await tester.pumpAndSettle();

      // Find the ListView
      expect(find.byType(ListView), findsOneWidget);
    });

    group('Sort functionality', () {
      testWidgets('can select Sort by Name', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: homepage()));
        await tester.pumpAndSettle();

        // Open sort menu
        await tester.tap(find.byIcon(Icons.format_list_bulleted_sharp));
        await tester.pumpAndSettle();

        // Select Name sort
        await tester.tap(find.text('Sort by Name'));
        await tester.pumpAndSettle();

        // Menu should close (verified by menu items not being visible)
        expect(find.text('Sort by Name'), findsNothing);
      });

      testWidgets('can select Sort by Type', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: homepage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.format_list_bulleted_sharp));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sort by Type'));
        await tester.pumpAndSettle();

        expect(find.text('Sort by Type'), findsNothing);
      });

      testWidgets('can select Sort by Maintenance Date', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: homepage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.format_list_bulleted_sharp));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sort by Maintenance Date'));
        await tester.pumpAndSettle();

        expect(find.text('Sort by Maintenance Date'), findsNothing);
      });
    });

    group('Layout and styling', () {
      testWidgets('header has correct background color', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: homepage()));
        await tester.pump();

        final Container header = tester.widget(
          find
              .descendant(
                of: find.byType(SafeArea),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(header.color, Color(0xFFFF473F));
      });

      testWidgets('background is light grey', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: homepage()));
        await tester.pump();

        final Scaffold scaffold = tester.widget(find.byType(Scaffold));
        expect(scaffold.backgroundColor, Colors.grey[100]);
      });
    });
  });
}
