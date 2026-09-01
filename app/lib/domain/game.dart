import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/deal.dart';
import 'package:court_piece/domain/seat.dart';

/// Deal phase. Trump is named only in [WaitingTrump].
sealed class Phase {
  const Phase();
}

final class WaitingTrump extends Phase {
  const WaitingTrump();
}

final class Playing extends Phase {
  const Playing({required this.trump, this.trick = const []});

  final Suit trump;
  final List<Play> trick;
}

final class DealOver extends Phase {
  const DealOver({
    required this.trump,
    required this.winner,
    required this.court,
  });

  final Suit trump;
  final Team winner;
  final bool court;
}

final class MatchOver extends Phase {
  const MatchOver({required this.winner});

  final Team winner;
}

/// One card played into the current trick.
final class Play {
  const Play({required this.seat, required this.card});

  final Seat seat;
  final Card card;
}

/// A finished four-card trick.
final class CompletedTrick {
  const CompletedTrick({required this.winner, required this.plays});

  final Seat winner;
  final List<Play> plays;
}

/// Domain action. UI maps into these; it does not call deal functions.
sealed class Intent {
  const Intent();
}

final class CallTrump extends Intent {
  const CallTrump({required this.seat, required this.suit});

  final Seat seat;
  final Suit suit;
}

final class PlayCard extends Intent {
  const PlayCard({required this.seat, required this.card});

  final Seat seat;
  final Card card;
}

final class StartDeal extends Intent {
  const StartDeal();
}

enum RejectReason { wrongPhase, notYourTurn, cardNotHeld, mustFollowSuit }

sealed class ReduceResult {
  const ReduceResult();
}

final class Accept extends ReduceResult {
  const Accept(this.state);

  final GameState state;
}

final class Reject extends ReduceResult {
  const Reject(this.reason);

  final RejectReason reason;
}

const matchCourts = 7;

/// Immutable match snapshot.
final class GameState {
  const GameState._({
    required this.deal,
    required this.phase,
    required this.toAct,
    required this.completed,
    required this.seed,
    required this.northSouthCourts,
    required this.eastWestCourts,
  });

  final Deal deal;
  final Phase phase;
  final Seat toAct;
  final List<CompletedTrick> completed;
  final int seed;
  final int northSouthCourts;
  final int eastWestCourts;

  factory GameState.match({required int seed, Seat? dealer}) {
    final first =
        dealer ?? Seat.values[seed.toUnsigned(32) % Seat.values.length];
    return GameState.dealtFive(seed: seed, dealer: first);
  }

  factory GameState.dealtFive({
    required int seed,
    required Seat dealer,
    int northSouthCourts = 0,
    int eastWestCourts = 0,
  }) {
    final deal = dealFive(deck: shuffledDeck(seed), dealer: dealer);
    return GameState._(
      deal: deal,
      phase: const WaitingTrump(),
      toAct: deal.hakem,
      completed: const [],
      seed: seed,
      northSouthCourts: northSouthCourts,
      eastWestCourts: eastWestCourts,
    );
  }

  GameState copyWith({
    Deal? deal,
    Phase? phase,
    Seat? toAct,
    List<CompletedTrick>? completed,
    int? seed,
    int? northSouthCourts,
    int? eastWestCourts,
  }) {
    return GameState._(
      deal: deal ?? this.deal,
      phase: phase ?? this.phase,
      toAct: toAct ?? this.toAct,
      completed: completed ?? this.completed,
      seed: seed ?? this.seed,
      northSouthCourts: northSouthCourts ?? this.northSouthCourts,
      eastWestCourts: eastWestCourts ?? this.eastWestCourts,
    );
  }
}
