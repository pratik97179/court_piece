import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/application/game_session.dart';
import 'package:court_piece/design/design.dart';
import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:court_piece/infrastructure/png_card_art.dart';
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

  testWidgets('north sits near the trick and the hand sits under the table', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(_app(_FakeSession(_demoView())));
    await tester.pumpAndSettle();

    final table = tester.getRect(find.byType(GameTable));
    final north = tester.getRect(find.byKey(const ValueKey<String>('north-0')));
    final trick = tester.getRect(
      find.byKey(const ValueKey<String>('well-north-3H')),
    );
    final hand = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );

    expect(trick.top - north.bottom, lessThan(table.height * 0.16));
    expect(hand.top, greaterThan(trick.bottom));
    expect(hand.top - north.bottom, lessThan(table.height * 0.65));
  });

  testWidgets('thirteen south cards fan from an upright center by pi/25', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    const thirteen = [
      Card(rank: Rank.ace, suit: Suit.hearts),
      Card(rank: Rank.king, suit: Suit.hearts),
      Card(rank: Rank.queen, suit: Suit.hearts),
      Card(rank: Rank.jack, suit: Suit.hearts),
      Card(rank: Rank.ten, suit: Suit.hearts),
      Card(rank: Rank.nine, suit: Suit.hearts),
      Card(rank: Rank.eight, suit: Suit.hearts),
      Card(rank: Rank.seven, suit: Suit.hearts),
      Card(rank: Rank.six, suit: Suit.hearts),
      Card(rank: Rank.five, suit: Suit.hearts),
      Card(rank: Rank.four, suit: Suit.hearts),
      Card(rank: Rank.three, suit: Suit.hearts),
      Card(rank: Rank.two, suit: Suit.hearts),
    ];
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      _app(_FakeSession(_demoView(south: thirteen, trick: const []))),
    );
    expect(PivotHand.angleAt(index: 6, center: 6), 0);
    expect(PivotHand.angleAt(index: 5, center: 6), -PivotHand.step);
    expect(PivotHand.angleAt(index: 7, center: 6), PivotHand.step);
    expect(PivotHand.angleAt(index: 0, center: 6), -6 * PivotHand.step);
    expect(PivotHand.angleAt(index: 12, center: 6), 6 * PivotHand.step);
    final rail = tester.getSize(find.byType(SeatRail));
    final card = tester.getSize(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.seven, suit: ArtSuit.hearts),
        ),
      ),
    );
    expect(rail.width, lessThanOrEqualTo(card.width * SeatRail.spreadWidths + 1));
    expect(rail.height, greaterThan(card.height * 0.5));
  });

  testWidgets('thirteen south cards share one pivot fan on desktop', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    const thirteen = [
      Card(rank: Rank.ace, suit: Suit.hearts),
      Card(rank: Rank.king, suit: Suit.hearts),
      Card(rank: Rank.queen, suit: Suit.hearts),
      Card(rank: Rank.jack, suit: Suit.hearts),
      Card(rank: Rank.ten, suit: Suit.hearts),
      Card(rank: Rank.nine, suit: Suit.hearts),
      Card(rank: Rank.eight, suit: Suit.hearts),
      Card(rank: Rank.seven, suit: Suit.hearts),
      Card(rank: Rank.six, suit: Suit.hearts),
      Card(rank: Rank.five, suit: Suit.hearts),
      Card(rank: Rank.four, suit: Suit.hearts),
      Card(rank: Rank.three, suit: Suit.hearts),
      Card(rank: Rank.two, suit: Suit.hearts),
    ];
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      _app(_FakeSession(_demoView(south: thirteen, trick: const []))),
    );
    final layout = PivotHand.layout(count: 12, cardWidth: 80);
    expect(layout.centerIndex, 6);
    expect(PivotHand.angleAt(index: 0, center: 6), -6 * PivotHand.step);
    expect(PivotHand.angleAt(index: 11, center: 6), 5 * PivotHand.step);
    final rail = tester.getSize(find.byType(SeatRail));
    final card = tester.getSize(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.seven, suit: ArtSuit.hearts),
        ),
      ),
    );
    expect(rail.width, lessThanOrEqualTo(card.width * SeatRail.spreadWidths + 1));
  });

  testWidgets('rebuilds when the session view changes', (tester) async {
    final session = _FakeSession(_demoView());
    await tester.pumpWidget(_app(session));
    expect(find.byType(SeatRail), findsOneWidget);
    expect(find.byType(OpponentSeat), findsNWidgets(3));
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
    expect(find.byKey(const ValueKey<String>('north-count')), findsOneWidget);
  });

  testWidgets('opponent fans stay compact and spread like real hands', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      _app(
        _FakeSession(
          _demoView(
            northCount: 13,
            westCount: 13,
            eastCount: 13,
            trick: const [],
          ),
        ),
      ),
    );
    final table = tester.getRect(find.byType(GameTable));
    final first = tester.getRect(find.byKey(const ValueKey<String>('north-0')));
    final last = tester.getRect(find.byKey(const ValueKey<String>('north-12')));
    expect(last.right - first.left, lessThan(table.width * 0.32));
    expect(last.right - first.left, greaterThan(first.width * 1.4));
    expect(
      first.width,
      lessThan(tester.getSize(find.byType(SeatRail)).width * 0.5),
    );
    final westLow = tester.getRect(find.byKey(const ValueKey<String>('west-0')));
    final westHigh = tester.getRect(
      find.byKey(const ValueKey<String>('west-12')),
    );
    expect((westHigh.center.dy - westLow.center.dy).abs(), greaterThan(24));
    expect((westHigh.center.dx - westLow.center.dx).abs(), lessThan(20));
    expect(find.byKey(const ValueKey<String>('north-avatar')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('north-count')), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('north-count')))
          .data,
      '13',
    );
    expect(find.byKey(const ValueKey<String>('west-avatar')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('east-count')), findsOneWidget);
  });

  testWidgets('south hand pivots from the upright center on mobile', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    const thirteen = [
      Card(rank: Rank.ace, suit: Suit.hearts),
      Card(rank: Rank.king, suit: Suit.hearts),
      Card(rank: Rank.queen, suit: Suit.hearts),
      Card(rank: Rank.jack, suit: Suit.hearts),
      Card(rank: Rank.ten, suit: Suit.hearts),
      Card(rank: Rank.nine, suit: Suit.hearts),
      Card(rank: Rank.eight, suit: Suit.hearts),
      Card(rank: Rank.seven, suit: Suit.hearts),
      Card(rank: Rank.six, suit: Suit.hearts),
      Card(rank: Rank.five, suit: Suit.hearts),
      Card(rank: Rank.four, suit: Suit.hearts),
      Card(rank: Rank.three, suit: Suit.hearts),
      Card(rank: Rank.two, suit: Suit.hearts),
    ];
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      _app(_FakeSession(_demoView(south: thirteen, trick: const []))),
    );
    final edge = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );
    final middle = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.seven, suit: ArtSuit.hearts),
        ),
      ),
    );
    expect((edge.center.dx - middle.center.dx).abs(), greaterThan(8));
  });

  testWidgets('south hand pivots from the upright center on desktop', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    const thirteen = [
      Card(rank: Rank.ace, suit: Suit.hearts),
      Card(rank: Rank.king, suit: Suit.hearts),
      Card(rank: Rank.queen, suit: Suit.hearts),
      Card(rank: Rank.jack, suit: Suit.hearts),
      Card(rank: Rank.ten, suit: Suit.hearts),
      Card(rank: Rank.nine, suit: Suit.hearts),
      Card(rank: Rank.eight, suit: Suit.hearts),
      Card(rank: Rank.seven, suit: Suit.hearts),
      Card(rank: Rank.six, suit: Suit.hearts),
      Card(rank: Rank.five, suit: Suit.hearts),
      Card(rank: Rank.four, suit: Suit.hearts),
      Card(rank: Rank.three, suit: Suit.hearts),
      Card(rank: Rank.two, suit: Suit.hearts),
    ];
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      _app(_FakeSession(_demoView(south: thirteen, trick: const []))),
    );
    final left = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );
    final right = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.two, suit: ArtSuit.hearts),
        ),
      ),
    );
    final center = tester.getRect(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.seven, suit: ArtSuit.hearts),
        ),
      ),
    );
    expect(left.center.dx, lessThan(center.center.dx));
    expect(right.center.dx, greaterThan(center.center.dx));
  });

  testWidgets('trump overlay is hidden while playing', (tester) async {
    await tester.pumpWidget(_app(_FakeSession(_demoView())));
    expect(find.byType(CourtOverlay), findsNothing);
    expect(find.text('Name trump'), findsNothing);
  });

  testWidgets('south hakem sees trump overlay and can call hearts', (
    tester,
  ) async {
    final session = _FakeSession(
      _demoView(
        phase: TablePhase.waitingTrump,
        toAct: Seat.south,
        trump: null,
        south: const [
          Card(rank: Rank.ace, suit: Suit.hearts),
          Card(rank: Rank.king, suit: Suit.diamonds),
          Card(rank: Rank.queen, suit: Suit.spades),
          Card(rank: Rank.jack, suit: Suit.hearts),
          Card(rank: Rank.nine, suit: Suit.spades),
        ],
        trick: const [],
      ),
    );
    await tester.pumpWidget(_app(session));
    expect(find.byType(CourtOverlay), findsOneWidget);
    expect(find.text('Name trump'), findsOneWidget);
    expect(find.byType(GameTable), findsOneWidget);
    final scrim = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(CourtOverlay),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(scrim.color, CourtTheme.light().felt);
    expect(scrim.color.a, 1);

    await tester.tap(find.byKey(const ValueKey<String>('trump-hearts')));
    await tester.pump();

    expect(session.intents, hasLength(1));
    expect(session.intents.single, isA<CallTrumpIntent>());
    expect((session.intents.single as CallTrumpIntent).suit, Suit.hearts);
  });

  testWidgets('trump overlay stays off when south is not hakem', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _FakeSession(
          _demoView(
            phase: TablePhase.waitingTrump,
            toAct: Seat.east,
            trump: null,
            trick: const [],
          ),
        ),
      ),
    );
    expect(find.byType(CourtOverlay), findsNothing);
  });

  testWidgets('tap on a legal south card sends playCard', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    const aceHearts = Card(rank: Rank.ace, suit: Suit.hearts);
    const kingDiamonds = Card(rank: Rank.king, suit: Suit.diamonds);
    final session = _FakeSession(
      _demoView(
        south: const [aceHearts, kingDiamonds],
        trick: [
          TablePlay(
            seat: Seat.north,
            card: const Card(rank: Rank.three, suit: Suit.hearts),
          ),
        ],
        legalSouth: const [aceHearts],
      ),
    );
    await tester.pumpWidget(_app(session));

    final playable = tester.widget<PlayingCard>(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );
    final idle = tester.widget<PlayingCard>(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.king, suit: ArtSuit.diamonds),
        ),
      ),
    );
    expect(playable.presence, CardPresence.playable);
    expect(idle.presence, CardPresence.idle);

    idle.onTap!.call();
    await tester.pump();
    expect(session.intents, isEmpty);

    playable.onTap!.call();
    await tester.pump();
    expect(session.intents, hasLength(1));
    expect(session.intents.single, isA<PlayCardIntent>());
    expect((session.intents.single as PlayCardIntent).card, aceHearts);
  });

  testWidgets('tap on a lone legal south card sends playCard', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    const aceHearts = Card(rank: Rank.ace, suit: Suit.hearts);
    final session = _FakeSession(
      _demoView(
        south: const [aceHearts],
        trick: [
          TablePlay(
            seat: Seat.north,
            card: const Card(rank: Rank.three, suit: Suit.hearts),
          ),
        ],
        legalSouth: const [aceHearts],
      ),
    );
    await tester.pumpWidget(_app(session));
    await tester.tap(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );
    await tester.pump();
    expect(session.intents, hasLength(1));
    expect((session.intents.single as PlayCardIntent).card, aceHearts);
  });

  testWidgets('south cards stay idle when it is not south turn', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    const aceHearts = Card(rank: Rank.ace, suit: Suit.hearts);
    final session = _FakeSession(
      _demoView(
        toAct: Seat.east,
        south: const [aceHearts],
        trick: const [],
        legalSouth: const [],
      ),
    );
    await tester.pumpWidget(_app(session));
    expect(
      tester
          .widget<PlayingCard>(
            find.byKey(
              const ValueKey<CardArtId>(
                CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
              ),
            ),
          )
          .presence,
      CardPresence.idle,
    );
    await tester.tap(
      find.byKey(
        const ValueKey<CardArtId>(
          CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
        ),
      ),
    );
    await tester.pump();
    expect(session.intents, isEmpty);
    expect(
      tester
          .widget<PlayingCard>(
            find.byKey(
              const ValueKey<CardArtId>(
                CardArtId(rank: ArtRank.ace, suit: ArtSuit.hearts),
              ),
            ),
          )
          .presence,
      CardPresence.selected,
    );
  });

  testWidgets('score pips and trump mark show during play', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      _app(
        _FakeSession(
          _demoView(
            northSouthTricks: 3,
            eastWestTricks: 2,
            northSouthCourts: 1,
            eastWestCourts: 0,
            trump: Suit.spades,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('score-pips')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('trump-mark-spades')), findsOneWidget);
  });

  testWidgets('dealt cards enter through CourtEnter', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      _app(
        _FakeSession(
          _demoView(
            south: const [
              Card(rank: Rank.ace, suit: Suit.hearts),
              Card(rank: Rank.king, suit: Suit.diamonds),
              Card(rank: Rank.queen, suit: Suit.spades),
            ],
            northCount: 3,
            eastCount: 3,
            westCount: 3,
            trick: const [],
          ),
        ),
      ),
    );

    expect(find.byType(CourtEnter), findsNWidgets(12));
    expect(
      find.byKey(const ValueKey<String>('enter-south-AH-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('enter-north-0-1')),
      findsOneWidget,
    );
  });

  testWidgets('deal over overlay starts the next deal', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    final session = _FakeSession(
      _demoView(
        phase: TablePhase.dealOver,
        dealWinner: Team.northSouth,
        dealCourt: true,
        trump: Suit.hearts,
        trick: const [],
        south: const [],
        legalSouth: const [],
      ),
    );
    await tester.pumpWidget(_app(session));
    await tester.pumpAndSettle();

    expect(find.text('Court'), findsOneWidget);
    expect(find.text('Your team wins'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('next-deal')));
    expect(session.intents, [const StartDealIntent()]);
  });

  testWidgets('match over overlay offers leave', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      _app(
        _FakeSession(
          _demoView(
            phase: TablePhase.matchOver,
            matchWinner: Team.eastWest,
            trump: Suit.hearts,
            trick: const [],
            south: const [],
            legalSouth: const [],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Match won'), findsOneWidget);
    expect(find.text('Opponents win'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('leave-match')), findsOneWidget);
  });
}

Widget _app(GameSession session) {
  return MaterialApp(
    theme: CourtTheme.light().asMaterial(),
    home: TablePage(session: session, art: const PngCardArt()),
  );
}

Offset _cardPoint(WidgetTester tester, Finder finder, Offset fraction) {
  final box = tester.renderObject<RenderBox>(finder);
  return box.localToGlobal(
    Offset(box.size.width * fraction.dx, box.size.height * fraction.dy),
  );
}

TableView _demoView({
  List<Card>? south,
  int northCount = 5,
  int eastCount = 5,
  int westCount = 5,
  TablePhase phase = TablePhase.playing,
  Seat toAct = Seat.south,
  Suit? trump = Suit.hearts,
  List<TablePlay>? trick,
  List<Card> legalSouth = const [],
  int northSouthTricks = 0,
  int eastWestTricks = 0,
  int northSouthCourts = 0,
  int eastWestCourts = 0,
  Team? dealWinner,
  bool dealCourt = false,
  Team? matchWinner,
}) {
  return TableView(
    phase: phase,
    toAct: toAct,
    hakem: Seat.south,
    dealer: Seat.west,
    trump: trump,
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
    eastCount: eastCount,
    westCount: westCount,
    trick:
        trick ??
        [
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
    northSouthTricks: northSouthTricks,
    eastWestTricks: eastWestTricks,
    northSouthCourts: northSouthCourts,
    eastWestCourts: eastWestCourts,
    legalSouth: legalSouth,
    dealWinner: dealWinner,
    dealCourt: dealCourt,
    matchWinner: matchWinner,
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

  final intents = <PlayerIntent>[];

  @override
  void submit(PlayerIntent intent) {
    intents.add(intent);
  }

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
