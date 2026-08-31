import 'package:court_piece/app.dart';
import 'package:court_piece/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toggles light and dark CourtTheme', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const CourtApp());

    expect(find.byType(CourtScreen), findsOneWidget);
    expect(
      CourtTheme.of(tester.element(find.byType(CourtScreen))).brightness,
      Brightness.light,
    );
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('theme-toggle')));
    await tester.pumpAndSettle();

    expect(
      CourtTheme.of(tester.element(find.byType(CourtScreen))).brightness,
      Brightness.dark,
    );
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}
