import 'card.dart';
import 'seat.dart';

sealed class Phase {
  const Phase();
}

class AwaitingTrump extends Phase {
  const AwaitingTrump();
}

class Playing extends Phase {
  const Playing();
}

class DealOver extends Phase {
  const DealOver({
    required this.winner,
    required this.kot,
  });

  final Team winner;
  final bool kot;
}

class MatchOver extends Phase {
  const MatchOver({required this.winner});

  final Team winner;
}

class PlayedCard {
  const PlayedCard({required this.seat, required this.card});

  final Seat seat;
  final Card card;
}
