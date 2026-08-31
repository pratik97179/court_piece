import 'package:court_piece/app.dart';
import 'package:court_piece/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home uses grammar and toggles theme', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const CourtApp());

    expect(find.byType(CourtScreen), findsOneWidget);
    expect(find.byType(CourtHeader), findsOneWidget);
    expect(find.byType(CourtCluster), findsOneWidget);
    expect(find.text('Court Piece'), findsOneWidget);
    expect(
      CourtTheme.of(tester.element(find.byType(CourtScreen))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byKey(const ValueKey<String>('theme-toggle')));
    await tester.pumpAndSettle();

    expect(
      CourtTheme.of(tester.element(find.byType(CourtScreen))).brightness,
      Brightness.dark,
    );
  });
}
