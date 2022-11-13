import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:temp_min/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that there is a button to add wake time
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
