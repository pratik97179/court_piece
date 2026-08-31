import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/deal.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/seat.dart';

/// Apply [intent] or return a typed [Reject]. Never throws for illegal play.
ReduceResult reduce(GameState state, Intent intent) {
  return switch (intent) {
    CallTrump(:final seat, :final suit) => _callTrump(state, seat, suit),
    PlayCard(:final seat, :final card) => _playCard(state, seat, card),
  };
}

/// Cards [seat] may play now. Empty if it is not a play phase.
List<Card> legalPlays(GameState state, Seat seat) {
  final phase = state.phase;
  if (phase is! Playing || seat != state.toAct) {
    return const [];
  }
  final hand = state.deal.hand(seat);
  if (phase.trick.isEmpty) {
    return List<Card>.of(hand);
  }
  final lead = phase.trick.first.card.suit;
  final follow = [
    for (final card in hand)
      if (card.suit == lead) card,
  ];
  return follow.isEmpty ? List<Card>.of(hand) : follow;
}

/// Winner of a four-card trick. Highest trump, else highest of the led suit.
Seat trickWinner(List<Play> plays, Suit trump) {
  var best = plays.first;
  final lead = best.card.suit;
  for (final play in plays.skip(1)) {
    if (_beats(play.card, best.card, lead: lead, trump: trump)) {
      best = play;
    }
  }
  return best.seat;
}

ReduceResult _callTrump(GameState state, Seat seat, Suit suit) {
  if (state.phase is! WaitingTrump) {
    return const Reject(RejectReason.wrongPhase);
  }
  if (seat != state.toAct || seat != state.deal.hakem) {
    return const Reject(RejectReason.notYourTurn);
  }
  return Accept(GameState.playing(deal: dealRest(state.deal), trump: suit));
}

ReduceResult _playCard(GameState state, Seat seat, Card card) {
  final phase = state.phase;
  if (phase is! Playing) {
    return const Reject(RejectReason.wrongPhase);
  }
  if (seat != state.toAct) {
    return const Reject(RejectReason.notYourTurn);
  }
  if (!state.deal.hand(seat).contains(card)) {
    return const Reject(RejectReason.cardNotHeld);
  }
  if (!legalPlays(state, seat).contains(card)) {
    return const Reject(RejectReason.mustFollowSuit);
  }
  final trick = [...phase.trick, Play(seat: seat, card: card)];
  final deal = state.deal.without(seat, card);
  if (trick.length < 4) {
    return Accept(
      GameState.playing(
        deal: deal,
        trump: phase.trump,
        trick: trick,
        completed: state.completed,
        toAct: seat.next,
      ),
    );
  }
  final winner = trickWinner(trick, phase.trump);
  return Accept(
    GameState.playing(
      deal: deal,
      trump: phase.trump,
      completed: [
        ...state.completed,
        CompletedTrick(winner: winner, plays: trick),
      ],
      toAct: winner,
    ),
  );
}

bool _beats(
  Card challenger,
  Card incumbent, {
  required Suit lead,
  required Suit trump,
}) {
  final challengerTrump = challenger.suit == trump;
  final incumbentTrump = incumbent.suit == trump;
  if (challengerTrump != incumbentTrump) {
    return challengerTrump;
  }
  if (challenger.suit != incumbent.suit) {
    return false;
  }
  if (challenger.suit != lead && !challengerTrump) {
    return false;
  }
  return challenger.rank.power > incumbent.rank.power;
}
