import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/application/game_session.dart';
import 'package:court_piece/design/design.dart';
import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:court_piece/infrastructure/svg_card_art.dart';
import 'package:court_piece/table/table_page.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hand cards are larger than opponent cards and stay 5:7', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(_app(_FakeSession(_demoView())));

    final hand = tester.getSize(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );
    final opponent = tester.getSize(
      find.byKey(const ValueKey<String>('north-0')),
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
      await tester.pumpWidget(_app(_FakeSession(_demoView())));
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
    await tester.pumpWidget(_app(_FakeSession(_demoView())));

    final table = tester.getRect(find.byType(GameTable));
    final north = tester.getRect(find.byKey(const ValueKey<String>('north-0')));
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

  testWidgets('rebuilds when the session view changes', (tester) async {
    final session = _FakeSession(_demoView());
    await tester.pumpWidget(_app(session));
    expect(find.byType(SeatRail), findsNWidgets(4));
    expect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
      findsOneWidget,
    );

    session.view = _demoView(
      south: const [Card(rank: Rank.king, suit: Suit.diamonds)],
      northCount: 4,
    );
    session.notify();
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey<String>('north-3')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('north-4')), findsNothing);
  });
}

Widget _app(GameSession session) {
  return MaterialApp(
    theme: CourtTheme.light().asMaterial(),
    home: TablePage(session: session, art: const SvgCardArt()),
  );
}

TableView _demoView({List<Card>? south, int northCount = 5}) {
  return TableView(
    phase: TablePhase.playing,
    toAct: Seat.south,
    hakem: Seat.south,
    dealer: Seat.west,
    trump: Suit.hearts,
    southHand:
        south ??
        const [
          Card(rank: Rank.ace, suit: Suit.hearts),
          Card(rank: Rank.king, suit: Suit.diamonds),
          Card(rank: Rank.queen, suit: Suit.spades),
          Card(rank: Rank.jack, suit: Suit.hearts),
          Card(rank: Rank.nine, suit: Suit.spades),
          Card(rank: Rank.eight, suit: Suit.diamonds),
          Card(rank: Rank.seven, suit: Suit.hearts),
        ],
    northCount: northCount,
    eastCount: 5,
    westCount: 5,
    trick: [
      TablePlay(
        seat: Seat.north,
        card: const Card(rank: Rank.three, suit: Suit.hearts),
      ),
      TablePlay(
        seat: Seat.west,
        card: const Card(rank: Rank.five, suit: Suit.hearts),
      ),
      TablePlay(
        seat: Seat.east,
        card: const Card(rank: Rank.six, suit: Suit.spades),
      ),
      TablePlay(
        seat: Seat.south,
        card: const Card(rank: Rank.ten, suit: Suit.spades),
      ),
    ],
    northSouthTricks: 0,
    eastWestTricks: 0,
    northSouthCourts: 0,
    eastWestCourts: 0,
    legalSouth: const [],
  );
}

final class _FakeSession implements GameSession {
  _FakeSession(this.view);

  @override
  TableView view;

  final _listeners = <void Function()>[];

  void notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }

  @override
  void submit(PlayerIntent intent) {}

  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  @override
  List<TableEvent> takeEvents() => const [];

  @override
  void dispose() {}
}
