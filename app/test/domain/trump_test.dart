import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/deal.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/reduce.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dealt five waits on hakem for trump', () {
    final state = GameState.dealtFive(seed: 1, dealer: Seat.south);
    expect(state.phase, isA<WaitingTrump>());
    expect(state.toAct, Seat.east);
    expect(state.deal.hakem, Seat.east);
    expect(state.deal.hand(Seat.east), hasLength(5));
    expect(state.deal.stock, hasLength(32));
  });

  test('hakem callTrump names trump, deals the rest, and leads', () {
    final before = GameState.dealtFive(seed: 1, dealer: Seat.south);
    final result = reduce(
      before,
      const CallTrump(seat: Seat.east, suit: Suit.hearts),
    );
    expect(result, isA<Accept>());
    final next = (result as Accept).state;
    expect(next.phase, isA<Playing>());
    expect((next.phase as Playing).trump, Suit.hearts);
    expect(next.toAct, Seat.east);
    expect(next.deal.stock, isEmpty);
    for (final seat in Seat.values) {
      expect(next.deal.hand(seat), hasLength(13));
    }
    expect(next.deal.east, [
      ...before.deal.east,
      ...shuffledDeck(1).sublist(20, 28),
    ]);
  });

  test('non-hakem cannot call trump', () {
    final state = GameState.dealtFive(seed: 1, dealer: Seat.south);
    final result = reduce(
      state,
      const CallTrump(seat: Seat.south, suit: Suit.spades),
    );
    expect(result, isA<Reject>());
    expect((result as Reject).reason, RejectReason.notYourTurn);
  });

  test('callTrump after trump is named is rejected', () {
    final waiting = GameState.dealtFive(seed: 2, dealer: Seat.west);
    final accepted = reduce(
      waiting,
      const CallTrump(seat: Seat.south, suit: Suit.clubs),
    ) as Accept;
    final again = reduce(
      accepted.state,
      const CallTrump(seat: Seat.south, suit: Suit.diamonds),
    );
    expect(again, isA<Reject>());
    expect((again as Reject).reason, RejectReason.wrongPhase);
  });
}
