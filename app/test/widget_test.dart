import 'package:court_piece/app.dart';
import 'package:court_piece/design/design.dart';
import 'package:court_piece/home/home_page.dart';
import 'package:court_piece/table/table_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home uses grammar and toggles theme', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const CourtApp());

    expect(find.byType(CourtScreen), findsOneWidget);
    expect(find.byType(CourtHeader), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(GameTable), findsNothing);
    expect(find.text('Court Piece'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('play-local')), findsOneWidget);
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

  testWidgets('CourtScreen picks compact medium and expanded recipes', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    Future<CourtBreakpoint> breakpointAt(Size size) async {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const CourtApp());
      return CourtScope.of(tester.element(find.byType(CourtHeader))).breakpoint;
    }

    expect(await breakpointAt(const Size(390, 800)), CourtBreakpoint.compact);
    expect(await breakpointAt(const Size(700, 800)), CourtBreakpoint.medium);
    expect(await breakpointAt(const Size(1200, 800)), CourtBreakpoint.expanded);
  });

  testWidgets('Play opens TablePage from a session', (tester) async {
    await tester.pumpWidget(const CourtApp());
    await tester.tap(find.byKey(const ValueKey<String>('play-local')));
    await tester.pumpAndSettle();

    expect(find.byType(TablePage), findsOneWidget);
    expect(find.byType(GameTable), findsOneWidget);
    expect(find.byType(SeatRail), findsNWidgets(4));
    expect(find.byType(TrickWell), findsOneWidget);
  });
}
