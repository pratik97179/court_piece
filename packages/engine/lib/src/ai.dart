import 'action.dart';
import 'apply.dart';
import 'card.dart';
import 'phase.dart';
import 'seat.dart';
import 'state.dart';

/// Picks a legal action for [seat]. Never returns an illegal move.
Action? chooseAction(GameState state, Seat seat) {
  final legal = legalActions(state, seat);
  if (legal.isEmpty) {
    return null;
  }
  return switch (state.phase) {
    AwaitingTrump() => _chooseTrump(state, seat, legal),
    Playing() => _choosePlay(state, legal),
    DealOver() => legal.first,
    MatchOver() => null,
  };
}

Action _chooseTrump(GameState state, Seat seat, List<Action> legal) {
  final hand = state.hands[seat] ?? const <Card>[];
  var best = Suit.spades;
  var bestScore = -1;
  for (final suit in Suit.values) {
    final score = _suitScore(hand, suit);
    if (score > bestScore) {
      bestScore = score;
      best = suit;
    }
  }
  return legal.whereType<CallTrump>().firstWhere((a) => a.suit == best);
}

int _suitScore(List<Card> hand, Suit suit) {
  final ofSuit = hand.where((c) => c.suit == suit).toList();
  var honors = 0;
  for (final card in ofSuit) {
    honors += switch (card.rank) {
      Rank.ace => 5,
      Rank.king => 4,
      Rank.queen => 3,
      Rank.jack => 2,
      _ => 0,
    };
  }
  return ofSuit.length * 10 + honors;
}

Action _choosePlay(GameState state, List<Action> legal) {
  final plays = legal.whereType<PlayCard>().toList();
  plays.sort((a, b) => a.card.rank.index.compareTo(b.card.rank.index));
  if (state.trick.isEmpty) {
    return _lead(plays, state.trump);
  }
  final trump = state.trump!;
  final current = trickWinner(state.trick, trump);
  final partnerWinning = current.seat.team == plays.first.seat.team &&
      current.seat != plays.first.seat;
  if (partnerWinning) {
    return plays.first;
  }
  final winners = plays.where((p) {
    final next = [...state.trick, PlayedCard(seat: p.seat, card: p.card)];
    return trickWinner(next, trump).seat == p.seat;
  }).toList();
  if (winners.isNotEmpty) {
    return winners.first;
  }
  return plays.first;
}

Action _lead(List<PlayCard> plays, Suit? trump) {
  final aces = plays.where((p) => p.card.rank == Rank.ace).toList();
  if (aces.isNotEmpty) {
    final nonTrump = aces.where((p) => p.card.suit != trump);
    return (nonTrump.isNotEmpty ? nonTrump : aces).first;
  }
  final nonTrump = plays.where((p) => p.card.suit != trump).toList();
  final pool = nonTrump.isNotEmpty ? nonTrump : plays;
  return pool.reduce(
    (a, b) => a.card.rank.index <= b.card.rank.index ? a : b,
  );
}
