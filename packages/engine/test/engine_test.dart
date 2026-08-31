import 'package:court_piece_engine/court_piece_engine.dart';
import 'package:test/test.dart';

void main() {
  test('full deck is 52 unique cards', () {
    final deck = fullDeck();
    expect(deck.toSet(), hasLength(52));
    expect(Card.fromCode(const Card(Suit.spades, Rank.ace).code).suit, Suit.spades);
  });

  test('deal gives hakem five cards and waits for trump', () {
    final state = startMatch(seed: 1, dealer: Seat.south);
    expect(state.phase, isA<AwaitingTrump>());
    expect(state.hakem, Seat.east);
    expect(state.hands[state.hakem], hasLength(5));
    for (final seat in Seat.values) {
      expect(state.hands[seat], hasLength(5));
    }
    expect(state.undealt, hasLength(32));
    expect(legalActions(state, Seat.south), isEmpty);
    expect(legalActions(state, state.hakem), hasLength(4));
  });

  test('only hakem may call trump', () {
    final state = startMatch(seed: 1, dealer: Seat.south);
    final result = apply(
      state,
      const CallTrump(seat: Seat.south, suit: Suit.hearts),
    );
    expect(result, isA<ApplyIllegal>());
    expect((result as ApplyIllegal).reason, IllegalReason.notHakem);
  });

  test('must follow suit', () {
    var state = startMatch(seed: 2, dealer: Seat.north);
    state = _mustOk(state, CallTrump(seat: state.hakem, suit: Suit.spades));
    final leader = state.turn;
    final led = state.hands[leader]!.first;
    state = _mustOk(state, PlayCard(seat: leader, card: led));
    final next = state.turn;
    final offSuit = state.hands[next]!.firstWhere(
      (c) => c.suit != led.suit,
      orElse: () => led,
    );
    if (state.hasSuit(next, led.suit) && offSuit.suit != led.suit) {
      final result = apply(state, PlayCard(seat: next, card: offSuit));
      expect(result, isA<ApplyIllegal>());
      expect((result as ApplyIllegal).reason, IllegalReason.mustFollowSuit);
    }
  });

  test('trump wins over led suit', () {
    final trick = [
      PlayedCard(seat: Seat.south, card: const Card(Suit.hearts, Rank.ace)),
      PlayedCard(seat: Seat.east, card: const Card(Suit.hearts, Rank.king)),
      PlayedCard(seat: Seat.north, card: const Card(Suit.spades, Rank.two)),
      PlayedCard(seat: Seat.west, card: const Card(Suit.hearts, Rank.queen)),
    ];
    expect(trickWinner(trick, Suit.spades).seat, Seat.north);
  });

  test('highest of led suit wins when no trump', () {
    final trick = [
      PlayedCard(seat: Seat.south, card: const Card(Suit.hearts, Rank.ten)),
      PlayedCard(seat: Seat.east, card: const Card(Suit.hearts, Rank.ace)),
      PlayedCard(seat: Seat.north, card: const Card(Suit.clubs, Rank.ace)),
      PlayedCard(seat: Seat.west, card: const Card(Suit.hearts, Rank.king)),
    ];
    expect(trickWinner(trick, Suit.spades).seat, Seat.east);
  });

  test('after trump every seat has thirteen cards', () {
    var state = startMatch(seed: 3);
    state = _mustOk(state, CallTrump(seat: state.hakem, suit: Suit.hearts));
    expect(state.phase, isA<Playing>());
    expect(state.trump, Suit.hearts);
    expect(state.turn, state.hakem);
    expect(state.hands.values.every((h) => h.length == 13), isTrue);
    expect(state.undealt, isEmpty);
  });

  test('seven tricks with none for the other team is kot', () {
    var state = _playingShell(tricks: {Team.northSouth: 6, Team.eastWest: 0});
    state = _forceTrickWin(state, Seat.south);
    expect(state.phase, isA<DealOver>());
    expect((state.phase as DealOver).kot, isTrue);
    expect((state.phase as DealOver).winner, Team.northSouth);
    expect(state.courts[Team.northSouth], 1);
  });

  test('dealer stays when hakem team wins without kot', () {
    var state = _playingShell(
      dealer: Seat.north,
      hakem: Seat.west,
      tricks: {Team.northSouth: 3, Team.eastWest: 6},
    );
    state = _forceTrickWin(state, Seat.east);
    expect(state.phase, isA<DealOver>());
    expect((state.phase as DealOver).kot, isFalse);
    final dealer = state.dealer;
    state = _mustOk(state, const ContinueMatch(seat: Seat.south));
    expect(state.dealer, dealer);
    expect(state.phase, isA<AwaitingTrump>());
  });

  test('dealer becomes hakem when dealer team wins', () {
    var state = _playingShell(
      dealer: Seat.north,
      hakem: Seat.west,
      tricks: {Team.northSouth: 6, Team.eastWest: 2},
    );
    state = _forceTrickWin(state, Seat.south);
    expect((state.phase as DealOver).winner, Team.northSouth);
    state = _mustOk(state, const ContinueMatch(seat: Seat.south));
    expect(state.dealer, Seat.west);
  });

  test('match ends at target courts', () {
    var state = _playingShell(
      courts: {Team.northSouth: 6, Team.eastWest: 0},
      tricks: {Team.northSouth: 6, Team.eastWest: 1},
    );
    state = _forceTrickWin(state, Seat.south);
    expect(state.phase, isA<MatchOver>());
    expect((state.phase as MatchOver).winner, Team.northSouth);
    expect(legalActions(state, Seat.south), isEmpty);
  });

  test('hakem sees five cards, others do not', () {
    final state = startMatch(seed: 1, dealer: Seat.south);
    final hakem = viewFor(state, state.hakem);
    final other = viewFor(state, Seat.south);
    expect(hakem.hand, hasLength(5));
    expect(other.hand, isEmpty);
    expect(other.handCounts[Seat.east], 5);
    _assertNoLeak(state, other);
  });

  test('hidden hands after trump is set', () {
    var state = startMatch(seed: 3);
    state = _mustOk(state, CallTrump(seat: state.hakem, suit: Suit.hearts));
    final view = viewFor(state, Seat.south);
    expect(view.hand, hasLength(13));
    _assertNoLeak(state, view);
  });

  test('AI only emits legal actions across random matches', () {
    for (var seed = 0; seed < 40; seed++) {
      var state = startMatch(seed: seed, targetCourts: 2);
      var steps = 0;
      while (state.phase is! MatchOver && steps < 4000) {
        steps++;
        if (state.phase is DealOver) {
          state = _mustOk(state, const ContinueMatch(seat: Seat.south));
          continue;
        }
        final actor = state.phase is AwaitingTrump ? state.hakem : state.turn;
        final action = chooseAction(state, actor);
        expect(action, isNotNull, reason: 'seed $seed step $steps');
        final legal = legalActions(state, actor);
        expect(legal.any((a) => _sameAction(a, action!)), isTrue);
        state = _mustOk(state, action!);
      }
      expect(state.phase, isA<MatchOver>(), reason: 'seed $seed');
    }
  });
}

bool _sameAction(Action a, Action b) {
  if (a.runtimeType != b.runtimeType || a.seat != b.seat) {
    return false;
  }
  return switch (a) {
    CallTrump(:final suit) => b is CallTrump && b.suit == suit,
    PlayCard(:final card) => b is PlayCard && b.card == card,
    ContinueMatch() => b is ContinueMatch,
  };
}

void _assertNoLeak(GameState state, MatchView view) {
  final mine = state.hands[view.you]!.toSet();
  for (final card in view.hand) {
    expect(mine.contains(card), isTrue);
  }
  for (final seat in Seat.values) {
    if (seat == view.you) {
      continue;
    }
    for (final card in state.hands[seat]!) {
      expect(view.hand.contains(card), isFalse, reason: 'leaked $card from $seat');
    }
  }
}

GameState _mustOk(GameState state, Action action) {
  final result = apply(state, action);
  expect(result, isA<ApplyOk>(), reason: '$action on ${state.phase}');
  return (result as ApplyOk).state;
}

GameState _playingShell({
  Seat dealer = Seat.north,
  Seat? hakem,
  Map<Team, int>? tricks,
  Map<Team, int>? courts,
}) {
  final h = hakem ?? dealer.next;
  final deck = fullDeck();
  var i = 0;
  final hands = <Seat, List<Card>>{};
  for (final seat in Seat.values) {
    hands[seat] = deck.sublist(i, i + 13);
    i += 13;
  }
  return GameState(
    dealer: dealer,
    hakem: h,
    hands: hands,
    undealt: const [],
    phase: const Playing(),
    turn: Seat.south,
    trump: Suit.spades,
    trick: const [],
    trickLeader: Seat.south,
    tricks: tricks ?? {Team.northSouth: 0, Team.eastWest: 0},
    courts: courts ?? {Team.northSouth: 0, Team.eastWest: 0},
    targetCourts: 7,
    seed: 0,
  );
}

GameState _forceTrickWin(GameState state, Seat winner) {
  const trump = Suit.spades;
  const off = Suit.hearts;
  final follow = [
    const Card(off, Rank.two),
    const Card(off, Rank.three),
    const Card(off, Rank.four),
  ];
  final rest = fullDeck()
      .where((c) => c.suit != Suit.spades && !follow.contains(c))
      .toList();
  var i = 0;
  final hands = <Seat, List<Card>>{
    winner: fullDeck().where((c) => c.suit == Suit.spades).toList(),
  };
  var seat = winner.next;
  for (final card in follow) {
    hands[seat] = [card, ...rest.sublist(i, i + 12)];
    i += 12;
    seat = seat.next;
  }
  var next = state.copyWith(
    hands: hands,
    trump: trump,
    turn: winner,
    trick: const [],
  );
  next = _mustOk(next, PlayCard(seat: winner, card: const Card(trump, Rank.ace)));
  seat = winner.next;
  for (final card in follow) {
    next = _mustOk(next, PlayCard(seat: seat, card: card));
    seat = seat.next;
  }
  return next;
}
