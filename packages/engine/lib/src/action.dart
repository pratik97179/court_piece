import 'card.dart';
import 'seat.dart';

sealed class Action {
  const Action({required this.seat});

  final Seat seat;
}

class CallTrump extends Action {
  const CallTrump({required super.seat, required this.suit});

  final Suit suit;
}

class PlayCard extends Action {
  const PlayCard({required super.seat, required this.card});

  final Card card;
}

class ContinueMatch extends Action {
  const ContinueMatch({required super.seat});
}

enum IllegalReason {
  notYourTurn,
  wrongPhase,
  mustFollowSuit,
  cardNotInHand,
  notHakem,
  matchOver,
}
