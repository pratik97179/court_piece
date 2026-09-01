import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/reduce.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _playDeal(GameState state, Suit trump) {
  var next = state;
  if (next.phase is WaitingTrump) {
    next = (reduce(
      next,
      CallTrump(seat: next.toAct, suit: trump),
    ) as Accept).state;
  }
  while (next.phase is Playing) {
    final seat = next.toAct;
    final card = legalPlays(next, seat).first;
    next = (reduce(next, PlayCard(seat: seat, card: card)) as Accept).state;
  }
  return next;
}

void main() {
  test('match first dealer comes from the seed when omitted', () {
    final a = GameState.match(seed: 3);
    final b = GameState.match(seed: 3);
    expect(a.deal.dealer, b.deal.dealer);
    expect(a.phase, isA<WaitingTrump>());
    expect(a.northSouthCourts, 0);
    expect(a.eastWestCourts, 0);
  });

  test('losing team deals next so winners keep hakem', () {
    expect(nextDealer(Seat.south, Team.northSouth), Seat.north);
    expect(nextDealer(Seat.south, Team.eastWest), Seat.east);

    var state = GameState.match(seed: 1, dealer: Seat.south);
    state = _playDeal(state, Suit.hearts);
    expect(state.phase, isA<DealOver>());
    final winners = (state.phase as DealOver).winner;
    expect(
      winners == Team.northSouth
          ? state.northSouthCourts
          : state.eastWestCourts,
      1,
    );

    final started = (reduce(state, const StartDeal()) as Accept).state;
    expect(started.phase, isA<WaitingTrump>());
    expect(started.deal.dealer.team, isNot(winners));
    expect(started.deal.hakem.team, winners);
    expect(started.seed, 2);
  });

  test('seven courts wins the match', () {
    var state = GameState.dealtFive(
      seed: 1,
      dealer: Seat.south,
      northSouthCourts: 6,
      eastWestCourts: 6,
    );
    state = _playDeal(state, Suit.hearts);
    expect(state.phase, isA<MatchOver>());
    final winner = (state.phase as MatchOver).winner;
    expect(
      winner == Team.northSouth ? state.northSouthCourts : state.eastWestCourts,
      matchCourts,
    );
    expect(
      (reduce(state, const StartDeal()) as Reject).reason,
      RejectReason.wrongPhase,
    );
  });

  test('StartDeal is rejected while a deal is live', () {
    final state = GameState.match(seed: 1, dealer: Seat.west);
    expect(
      (reduce(state, const StartDeal()) as Reject).reason,
      RejectReason.wrongPhase,
    );
  });
}
