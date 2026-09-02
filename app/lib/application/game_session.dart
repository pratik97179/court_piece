import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/seat.dart';

/// Table contract. The page never sees GameState.
abstract interface class GameSession {
  TableView get view;

  void submit(PlayerIntent intent);

  void addListener(void Function() listener);

  void removeListener(void Function() listener);

  List<TableEvent> takeEvents();

  void dispose();
}

/// Sessions that can wait for table animations before the next turn.
abstract interface class PausableGameSession implements GameSession {
  void setActingPaused(bool paused);
}

/// Human action. The session maps this to a domain intent.
sealed class PlayerIntent {
  const PlayerIntent();
}

final class CallTrumpIntent extends PlayerIntent {
  const CallTrumpIntent(this.suit);

  final Suit suit;
}

final class PlayCardIntent extends PlayerIntent {
  const PlayCardIntent(this.card);

  final Card card;
}

final class StartDealIntent extends PlayerIntent {
  const StartDealIntent();
}

enum TablePhase { waitingTrump, playing, dealOver, matchOver }

enum TableReject { wrongPhase, notYourTurn, cardNotHeld, mustFollowSuit }

/// One card in the current trick.
final class TablePlay {
  const TablePlay({required this.seat, required this.card});

  final Seat seat;
  final Card card;

  @override
  bool operator ==(Object other) {
    return other is TablePlay && seat == other.seat && card == other.card;
  }

  @override
  int get hashCode => Object.hash(seat, card);
}

/// Game data the table may read.
final class TableView {
  const TableView({
    required this.phase,
    required this.toAct,
    required this.hakem,
    required this.dealer,
    required this.trump,
    required this.southHand,
    required this.northCount,
    required this.eastCount,
    required this.westCount,
    required this.trick,
    required this.northSouthTricks,
    required this.eastWestTricks,
    required this.northSouthCourts,
    required this.eastWestCourts,
    required this.legalSouth,
    this.dealWinner,
    this.dealCourt = false,
    this.matchWinner,
  });

  final TablePhase phase;
  final Seat toAct;
  final Seat hakem;
  final Seat dealer;
  final Suit? trump;
  final List<Card> southHand;
  final int northCount;
  final int eastCount;
  final int westCount;
  final List<TablePlay> trick;
  final int northSouthTricks;
  final int eastWestTricks;
  final int northSouthCourts;
  final int eastWestCourts;
  final List<Card> legalSouth;
  final Team? dealWinner;
  final bool dealCourt;
  final Team? matchWinner;
}

/// One-shot signal drained by [GameSession.takeEvents].
sealed class TableEvent {
  const TableEvent();
}

final class TableRejected extends TableEvent {
  const TableRejected(this.reason);

  final TableReject reason;

  @override
  bool operator ==(Object other) {
    return other is TableRejected && reason == other.reason;
  }

  @override
  int get hashCode => reason.hashCode;
}

final class TableDealOver extends TableEvent {
  const TableDealOver({required this.winner, required this.court});

  final Team winner;
  final bool court;
}

final class TableMatchOver extends TableEvent {
  const TableMatchOver(this.winner);

  final Team winner;
}

/// A four-card trick just finished. Used for the collect animation.
final class TableTrickWon extends TableEvent {
  const TableTrickWon({required this.winner, required this.plays});

  final Seat winner;
  final List<TablePlay> plays;

  @override
  bool operator ==(Object other) {
    return other is TableTrickWon &&
        winner == other.winner &&
        _playsEq(plays, other.plays);
  }

  @override
  int get hashCode => Object.hash(winner, Object.hashAll(plays));

  static bool _playsEq(List<TablePlay> a, List<TablePlay> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
