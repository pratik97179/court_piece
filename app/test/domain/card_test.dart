import 'package:court_piece/domain/card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deck is 52 unique cards, 13 per suit', () {
    expect(Card.deck, hasLength(52));
    expect(Card.deck.toSet(), hasLength(52));
    for (final suit in Suit.values) {
      expect(Card.deck.where((card) => card.suit == suit), hasLength(13));
    }
    for (final rank in Rank.values) {
      expect(Card.deck.where((card) => card.rank == rank), hasLength(4));
    }
  });

  test('equal when rank and suit match', () {
    const a = Card(rank: Rank.ace, suit: Suit.spades);
    const b = Card(rank: Rank.ace, suit: Suit.spades);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const Card(rank: Rank.ace, suit: Suit.hearts)));
    expect(a, isNot(const Card(rank: Rank.king, suit: Suit.spades)));
  });

  test('code round-trips for every card', () {
    for (final card in Card.deck) {
      expect(Card.parse(card.code), card);
    }
    expect(const Card(rank: Rank.ace, suit: Suit.spades).code, 'AS');
    expect(const Card(rank: Rank.ten, suit: Suit.hearts).code, 'TH');
  });

  test('parse rejects malformed codes', () {
    expect(() => Card.parse('A'), throwsFormatException);
    expect(() => Card.parse('ASX'), throwsFormatException);
    expect(() => Card.parse('AX'), throwsFormatException);
    expect(() => Card.parse('1S'), throwsFormatException);
  });
}
