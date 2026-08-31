import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/reduce.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter_test/flutter_test.dart';

CompletedTrick _won(Seat seat) {
  return CompletedTrick(winner: seat, plays: const []);
}

void main() {
  test('deal stays open before either team has seven tricks', () {
    expect(
      dealOutcome([
        _won(Seat.south),
        _won(Seat.east),
        _won(Seat.north),
        _won(Seat.west),
        _won(Seat.south),
        _won(Seat.east),
      ], Suit.hearts),
      isNull,
    );
  });

  test('seven tricks wins; first seven in a row is a court', () {
    final sweep = [for (var i = 0; i < 7; i++) _won(Seat.south)];
    final court = dealOutcome(sweep, Suit.spades);
    expect(court, isNotNull);
    expect(court!.winner, Team.northSouth);
    expect(court.court, isTrue);

    final split = [
      _won(Seat.east),
      for (var i = 0; i < 7; i++) _won(Seat.north),
    ];
    final win = dealOutcome(split, Suit.clubs);
    expect(win!.winner, Team.northSouth);
    expect(win.court, isFalse);
  });

  test('reduce ends the deal at seven tricks and rejects further play', () {
    var state = GameState.dealtFive(seed: 1, dealer: Seat.south);
    state = (reduce(
      state,
      const CallTrump(seat: Seat.east, suit: Suit.hearts),
    ) as Accept).state;
    while (state.phase is Playing) {
      final seat = state.toAct;
      final card = legalPlays(state, seat).first;
      state = (reduce(state, PlayCard(seat: seat, card: card)) as Accept).state;
    }
    expect(state.phase, isA<DealOver>());
    final over = state.phase as DealOver;
    final ns = state.completed
        .where((trick) => trick.winner.team == Team.northSouth)
        .length;
    expect(ns >= 7 || state.completed.length - ns >= 7, isTrue);
    expect(over.court, state.completed.length == 7);
    expect(
      (reduce(
        state,
        PlayCard(seat: state.toAct, card: state.deal.hand(state.toAct).first),
      ) as Reject).reason,
      RejectReason.wrongPhase,
    );
  });
}
