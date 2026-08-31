import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/reduce.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _heartsPlay() {
  final waiting = GameState.dealtFive(seed: 1, dealer: Seat.south);
  return (reduce(
    waiting,
    const CallTrump(seat: Seat.east, suit: Suit.hearts),
  ) as Accept).state;
}

void main() {
  test('leader may play any held card, others wait', () {
    final state = _heartsPlay();
    expect(legalPlays(state, Seat.east), state.deal.east);
    expect(legalPlays(state, Seat.north), isEmpty);
    final card = state.deal.east.first;
    final offTurn = reduce(
      state,
      PlayCard(seat: Seat.north, card: state.deal.north.first),
    );
    expect((offTurn as Reject).reason, RejectReason.notYourTurn);
    final led = reduce(state, PlayCard(seat: Seat.east, card: card));
    expect(led, isA<Accept>());
    final next = (led as Accept).state;
    expect((next.phase as Playing).trick, hasLength(1));
    expect(next.toAct, Seat.north);
    expect(next.deal.east, isNot(contains(card)));
  });

  test('must follow the led suit when holding it', () {
    final state = _heartsPlay();
    final lead = state.deal.east.firstWhere(
      (card) => state.deal.north.any((held) => held.suit == card.suit),
    );
    final afterLead =
        (reduce(state, PlayCard(seat: Seat.east, card: lead)) as Accept).state;
    final off = afterLead.deal.north.firstWhere(
      (card) => card.suit != lead.suit,
    );
    final rejected = reduce(afterLead, PlayCard(seat: Seat.north, card: off));
    expect((rejected as Reject).reason, RejectReason.mustFollowSuit);
    final follow = afterLead.deal.north.firstWhere(
      (card) => card.suit == lead.suit,
    );
    expect(
      reduce(afterLead, PlayCard(seat: Seat.north, card: follow)),
      isA<Accept>(),
    );
  });

  test('void of the lead may play any held card', () {
    for (var seed = 1; seed <= 40; seed++) {
      final waiting = GameState.dealtFive(seed: seed, dealer: Seat.south);
      final playing = (reduce(
        waiting,
        const CallTrump(seat: Seat.east, suit: Suit.hearts),
      ) as Accept).state;
      final lead = playing.deal.east
          .where(
            (card) =>
                playing.deal.north.every((held) => held.suit != card.suit),
          )
          .firstOrNull;
      if (lead == null) {
        continue;
      }
      final afterLead = (reduce(
        playing,
        PlayCard(seat: Seat.east, card: lead),
      ) as Accept).state;
      expect(legalPlays(afterLead, Seat.north), afterLead.deal.north);
      return;
    }
    fail('no seed where east can lead a suit north does not hold');
  });

  test('highest trump wins, else highest of the led suit', () {
    expect(
      trickWinner(const [
        Play(
          seat: Seat.east,
          card: Card(rank: Rank.ace, suit: Suit.spades),
        ),
        Play(
          seat: Seat.north,
          card: Card(rank: Rank.two, suit: Suit.hearts),
        ),
        Play(
          seat: Seat.west,
          card: Card(rank: Rank.king, suit: Suit.spades),
        ),
        Play(
          seat: Seat.south,
          card: Card(rank: Rank.queen, suit: Suit.spades),
        ),
      ], Suit.hearts),
      Seat.north,
    );
    expect(
      trickWinner(const [
        Play(
          seat: Seat.east,
          card: Card(rank: Rank.two, suit: Suit.spades),
        ),
        Play(
          seat: Seat.north,
          card: Card(rank: Rank.king, suit: Suit.spades),
        ),
        Play(
          seat: Seat.west,
          card: Card(rank: Rank.ace, suit: Suit.spades),
        ),
        Play(
          seat: Seat.south,
          card: Card(rank: Rank.three, suit: Suit.diamonds),
        ),
      ], Suit.hearts),
      Seat.west,
    );
    expect(
      trickWinner(const [
        Play(
          seat: Seat.east,
          card: Card(rank: Rank.five, suit: Suit.hearts),
        ),
        Play(
          seat: Seat.north,
          card: Card(rank: Rank.ace, suit: Suit.hearts),
        ),
        Play(
          seat: Seat.west,
          card: Card(rank: Rank.two, suit: Suit.spades),
        ),
        Play(
          seat: Seat.south,
          card: Card(rank: Rank.king, suit: Suit.hearts),
        ),
      ], Suit.hearts),
      Seat.north,
    );
  });

  test('fourth card completes the trick and the winner leads', () {
    var state = _heartsPlay();
    for (var i = 0; i < 4; i++) {
      final seat = state.toAct;
      final card = legalPlays(state, seat).first;
      state = (reduce(state, PlayCard(seat: seat, card: card)) as Accept).state;
    }
    expect((state.phase as Playing).trick, isEmpty);
    expect(state.completed, hasLength(1));
    expect(state.toAct, state.completed.single.winner);
    expect(state.completed.single.plays, hasLength(4));
  });

  test('playCard is rejected before trump and unknown cards are rejected', () {
    final waiting = GameState.dealtFive(seed: 1, dealer: Seat.south);
    expect(
      (reduce(
        waiting,
        const PlayCard(
          seat: Seat.east,
          card: Card(rank: Rank.ace, suit: Suit.spades),
        ),
      ) as Reject).reason,
      RejectReason.wrongPhase,
    );
    final playing = _heartsPlay();
    expect(
      (reduce(
        playing,
        const PlayCard(
          seat: Seat.east,
          card: Card(rank: Rank.ace, suit: Suit.hearts),
        ),
      ) as Reject).reason,
      RejectReason.cardNotHeld,
    );
  });
}
