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

/// Immutable match snapshot.
final class GameState {
  const GameState._({
    required this.deal,
    required this.phase,
    required this.toAct,
    required this.completed,
  });

  final Deal deal;
  final Phase phase;
  final Seat toAct;
  final List<CompletedTrick> completed;

  factory GameState.dealtFive({required int seed, required Seat dealer}) {
    final deal = dealFive(deck: shuffledDeck(seed), dealer: dealer);
    return GameState._(
      deal: deal,
      phase: const WaitingTrump(),
      toAct: deal.hakem,
      completed: const [],
    );
  }

  factory GameState.playing({
    required Deal deal,
    required Suit trump,
    List<Play> trick = const [],
    List<CompletedTrick> completed = const [],
    Seat? toAct,
  }) {
    return GameState._(
      deal: deal,
      phase: Playing(trump: trump, trick: trick),
      toAct: toAct ?? deal.hakem,
      completed: completed,
    );
  }

  factory GameState.over({
    required Deal deal,
    required DealOver phase,
    required List<CompletedTrick> completed,
    required Seat toAct,
  }) {
    return GameState._(
      deal: deal,
      phase: phase,
      toAct: toAct,
      completed: completed,
    );
  }
}
