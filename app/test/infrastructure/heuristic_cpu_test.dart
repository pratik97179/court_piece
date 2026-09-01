import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:court_piece/infrastructure/heuristic_cpu.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cpu = HeuristicCpu();

  test('pickTrump prefers the longest suit, then highest power', () {
    expect(
      cpu.pickTrump(const [
        Card(rank: Rank.ace, suit: Suit.hearts),
        Card(rank: Rank.king, suit: Suit.hearts),
        Card(rank: Rank.two, suit: Suit.spades),
        Card(rank: Rank.three, suit: Suit.clubs),
        Card(rank: Rank.four, suit: Suit.diamonds),
      ]),
      Suit.hearts,
    );
    expect(
      cpu.pickTrump(const [
        Card(rank: Rank.ace, suit: Suit.spades),
        Card(rank: Rank.two, suit: Suit.spades),
        Card(rank: Rank.king, suit: Suit.hearts),
        Card(rank: Rank.queen, suit: Suit.hearts),
      ]),
      Suit.hearts,
    );
  });

  test('leads the lowest non-trump when possible', () {
    expect(
      cpu.pickCard(
        legal: const [
          Card(rank: Rank.ace, suit: Suit.hearts),
          Card(rank: Rank.three, suit: Suit.spades),
          Card(rank: Rank.nine, suit: Suit.clubs),
        ],
        trump: Suit.hearts,
        trick: const [],
      ),
      const Card(rank: Rank.three, suit: Suit.spades),
    );
  });

  test('wins with the cheapest card that beats the current trick', () {
    expect(
      cpu.pickCard(
        legal: const [
          Card(rank: Rank.ace, suit: Suit.spades),
          Card(rank: Rank.queen, suit: Suit.spades),
          Card(rank: Rank.three, suit: Suit.spades),
        ],
        trump: Suit.hearts,
        trick: const [
          Play(
            seat: Seat.east,
            card: Card(rank: Rank.jack, suit: Suit.spades),
          ),
        ],
      ),
      const Card(rank: Rank.queen, suit: Suit.spades),
    );
  });

  test('dumps the lowest card when it cannot win', () {
    expect(
      cpu.pickCard(
        legal: const [
          Card(rank: Rank.nine, suit: Suit.spades),
          Card(rank: Rank.two, suit: Suit.spades),
        ],
        trump: Suit.hearts,
        trick: const [
          Play(
            seat: Seat.east,
            card: Card(rank: Rank.ace, suit: Suit.spades),
          ),
        ],
      ),
      const Card(rank: Rank.two, suit: Suit.spades),
    );
  });
}
