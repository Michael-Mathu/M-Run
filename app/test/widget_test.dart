import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwendo_app/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: MwendoApp()));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    // Onboarding is shown on a fresh install; its first slide proves the
    // theme, router and Phase 2 widget tree all build without error.
    expect(find.text('Run with Mwendo'), findsWidgets);
  });
}
