import 'package:court_piece/app.dart';
import 'package:court_piece/application/card_art.dart';
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
    expect(find.byType(GameTable), findsOneWidget);
    expect(find.byType(SeatRail), findsNWidgets(4));
    expect(find.byType(TrickWell), findsOneWidget);
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

  testWidgets('hand cards are larger than opponent cards and stay 5:7', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(const CourtApp());

    final hand = tester.getSize(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );
    final opponent = tester.getSize(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.two, suit: ArtSuit.clubs),
        ),
      ),
    );
    expect(hand.width, greaterThan(opponent.width));
    expect(hand.width / hand.height, closeTo(PlayingCard.aspect, 0.02));
    expect(opponent.width / opponent.height, closeTo(PlayingCard.aspect, 0.02));
  });

  testWidgets('table fits compact and expanded viewports', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    for (final size in const [
      Size(390, 800),
      Size(700, 800),
      Size(1200, 800),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const CourtApp());
      expect(tester.takeException(), isNull);
      expect(find.byType(GameTable), findsOneWidget);
      expect(find.byType(TrickWell), findsOneWidget);
    }
  });

  testWidgets('north sits near the trick and the hand sits near the bottom', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(const CourtApp());

    final table = tester.getRect(find.byType(GameTable));
    final north = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.two, suit: ArtSuit.clubs),
        ),
      ),
    );
    final trick = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.three, suit: ArtSuit.hearts),
        ),
      ),
    );
    final hand = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );

    expect(trick.top - north.bottom, lessThan(table.height * 0.16));
    expect(table.bottom - hand.bottom, lessThan(40));
  });
}
