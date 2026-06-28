// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendance_admin/app.dart';
import 'package:attendance_admin/routes/app_router.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('App should load without crashing', (WidgetTester tester) async {
    // Create a mock router to avoid Firebase dependency in tests
    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Mock App')),
        ),
      ],
    );

    // Build our app and trigger a frame.
    // We override routerProvider to use our mock router.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(mockRouter),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the mock app loaded.
    expect(find.text('Mock App'), findsOneWidget);
  });
}
