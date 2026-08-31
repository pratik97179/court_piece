import 'dart:math';

import 'action.dart';
import 'card.dart';
import 'phase.dart';
import 'seat.dart';
import 'state.dart';

sealed class ApplyResult {
  const ApplyResult();
}

class ApplyOk extends ApplyResult {
  const ApplyOk(this.state);

  final GameState state;
}

class ApplyIllegal extends ApplyResult {
  const ApplyIllegal(this.reason);

  final IllegalReason reason;
}

/// Starts a match, deals five cards, and waits for the hakem to call trump.
GameState startMatch({int? seed, Seat dealer = Seat.north, int targetCourts = 7}) {
  final used = seed ?? Random().nextInt(1 << 30);
  return _dealFive(
    dealer: dealer,
    courts: {Team.northSouth: 0, Team.eastWest: 0},
    targetCourts: targetCourts,
    seed: used,
    random: Random(used),
  );
}

/// Legal commands for [seat] in the current phase. Empty if they cannot act.
List<Action> legalActions(GameState state, Seat seat) {
  return switch (state.phase) {
    AwaitingTrump() => _legalTrump(state, seat),
    Playing() => _legalPlays(state, seat),
    DealOver() => [ContinueMatch(seat: seat)],
    MatchOver() => const [],
  };
}

/// Applies [action] when it is legal for the current phase and seat.
ApplyResult apply(GameState state, Action action) {
  return switch (state.phase) {
    MatchOver() => const ApplyIllegal(IllegalReason.matchOver),
    AwaitingTrump() => _applyTrump(state, action),
    Playing() => _applyPlay(state, action),
    DealOver() => _applyContinue(state, action),
  };
}

PlayedCard trickWinner(List<PlayedCard> trick, Suit trump) {
  assert(trick.isNotEmpty);
  final led = trick.first.card.suit;
  final trumps = trick.where((p) => p.card.suit == trump).toList();
  final pool = trumps.isNotEmpty
      ? trumps
      : trick.where((p) => p.card.suit == led).toList();
  return pool.reduce(
    (a, b) => a.card.rank.index >= b.card.rank.index ? a : b,
  );
}

List<Action> _legalTrump(GameState state, Seat seat) {
  if (seat != state.hakem) {
    return const [];
  }
  return [for (final suit in Suit.values) CallTrump(seat: seat, suit: suit)];
}

List<Action> _legalPlays(GameState state, Seat seat) {
  if (seat != state.turn) {
    return const [];
  }
  final hand = state.hands[seat] ?? const <Card>[];
  final led = state.ledSuit;
  final playable = led == null || !state.hasSuit(seat, led)
      ? hand
      : hand.where((c) => c.suit == led).toList();
  return [for (final card in playable) PlayCard(seat: seat, card: card)];
}

ApplyResult _applyTrump(GameState state, Action action) {
  if (action is! CallTrump) {
    return const ApplyIllegal(IllegalReason.wrongPhase);
  }
  if (action.seat != state.hakem) {
    return const ApplyIllegal(IllegalReason.notHakem);
  }
  var undealt = List<Card>.from(state.undealt);
  final hands = {
    for (final seat in Seat.values) seat: List<Card>.from(state.hands[seat]!),
  };
  for (var batch = 0; batch < 2; batch++) {
    for (var i = 0; i < Seat.values.length; i++) {
      var seat = state.hakem;
      for (var s = 0; s < i; s++) {
        seat = seat.next;
      }
      hands[seat]!.addAll(undealt.take(4));
      undealt = undealt.sublist(4);
    }
  }
  assert(undealt.isEmpty);
  for (final seat in Seat.values) {
    assert(hands[seat]!.length == 13);
  }
  _assertUnique(hands);
  return ApplyOk(
    state.copyWith(
      hands: hands,
      undealt: const [],
      phase: const Playing(),
      turn: state.hakem,
      trump: action.suit,
      trick: const [],
      trickLeader: state.hakem,
      tricks: {Team.northSouth: 0, Team.eastWest: 0},
    ),
  );
}

ApplyResult _applyPlay(GameState state, Action action) {
  if (action is! PlayCard) {
    return const ApplyIllegal(IllegalReason.wrongPhase);
  }
  if (action.seat != state.turn) {
    return const ApplyIllegal(IllegalReason.notYourTurn);
  }
  final hand = List<Card>.from(state.hands[action.seat] ?? const []);
  if (!hand.contains(action.card)) {
    return const ApplyIllegal(IllegalReason.cardNotInHand);
  }
  final led = state.ledSuit;
  if (led != null &&
      action.card.suit != led &&
      state.hasSuit(action.seat, led)) {
    return const ApplyIllegal(IllegalReason.mustFollowSuit);
  }
  hand.remove(action.card);
  final hands = {
    for (final seat in Seat.values)
      seat: seat == action.seat
          ? hand
          : List<Card>.from(state.hands[seat]!),
  };
  final trick = [...state.trick, PlayedCard(seat: action.seat, card: action.card)];
  if (trick.length < 4) {
    return ApplyOk(
      state.copyWith(
        hands: hands,
        trick: trick,
        turn: action.seat.next,
      ),
    );
  }
  return _finishTrick(state.copyWith(hands: hands, trick: trick));
}

ApplyResult _finishTrick(GameState state) {
  final trump = state.trump!;
  final winner = trickWinner(state.trick, trump);
  final tricks = Map<Team, int>.from(state.tricks);
  tricks[winner.seat.team] = (tricks[winner.seat.team] ?? 0) + 1;
  final won = tricks[winner.seat.team]!;
  if (won >= 7) {
    final kot = (tricks[winner.seat.team.opponent] ?? 0) == 0;
    final courts = Map<Team, int>.from(state.courts);
    courts[winner.seat.team] = (courts[winner.seat.team] ?? 0) + 1;
    final matchWon = courts[winner.seat.team]! >= state.targetCourts;
    return ApplyOk(
      state.copyWith(
        tricks: tricks,
        courts: courts,
        trick: const [],
        turn: winner.seat,
        phase: matchWon
            ? MatchOver(winner: winner.seat.team)
            : DealOver(winner: winner.seat.team, kot: kot),
      ),
    );
  }
  return ApplyOk(
    state.copyWith(
      tricks: tricks,
      trick: const [],
      turn: winner.seat,
      trickLeader: winner.seat,
    ),
  );
}

ApplyResult _applyContinue(GameState state, Action action) {
  if (action is! ContinueMatch) {
    return const ApplyIllegal(IllegalReason.wrongPhase);
  }
  final deal = state.phase as DealOver;
  final nextDealer = _nextDealer(
    dealer: state.dealer,
    hakem: state.hakem,
    winner: deal.winner,
    kot: deal.kot,
  );
  final nextSeed = state.seed + 1;
  return ApplyOk(
    _dealFive(
      dealer: nextDealer,
      courts: state.courts,
      targetCourts: state.targetCourts,
      seed: nextSeed,
      random: Random(nextSeed),
    ),
  );
}

Seat _nextDealer({
  required Seat dealer,
  required Seat hakem,
  required Team winner,
  required bool kot,
}) {
  if (winner == dealer.team) {
    return hakem;
  }
  if (kot) {
    return dealer.partner;
  }
  return dealer;
}

GameState _dealFive({
  required Seat dealer,
  required Map<Team, int> courts,
  required int targetCourts,
  required int seed,
  required Random random,
}) {
  final hakem = dealer.next;
  final deck = fullDeck()..shuffle(random);
  final hands = {for (final seat in Seat.values) seat: <Card>[]};
  var i = 0;
  for (var round = 0; round < 5; round++) {
    var seat = hakem;
    for (var s = 0; s < Seat.values.length; s++) {
      hands[seat]!.add(deck[i++]);
      seat = seat.next;
    }
  }
  return GameState(
    dealer: dealer,
    hakem: hakem,
    hands: hands,
    undealt: deck.sublist(i),
    phase: const AwaitingTrump(),
    turn: hakem,
    trump: null,
    trick: const [],
    trickLeader: hakem,
    tricks: {Team.northSouth: 0, Team.eastWest: 0},
    courts: Map<Team, int>.from(courts),
    targetCourts: targetCourts,
    seed: seed,
  );
}

void _assertUnique(Map<Seat, List<Card>> hands) {
  final seen = <Card>{};
  for (final cards in hands.values) {
    for (final card in cards) {
      assert(seen.add(card), 'duplicate $card');
    }
  }
  assert(seen.length == 52);
}
