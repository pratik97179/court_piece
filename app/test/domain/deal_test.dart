import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/deal.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hakem is the dealer next counter-clockwise', () {
    expect(Seat.south.next, Seat.east);
    expect(Seat.east.next, Seat.north);
    expect(Seat.north.next, Seat.west);
    expect(Seat.west.next, Seat.south);
  });

  test('same seed shuffles the same, and is a permutation of the deck', () {
    final a = shuffledDeck(1);
    final b = shuffledDeck(1);
    expect(a, b);
    expect(a.toSet(), Card.deck.toSet());
    expect(shuffledDeck(2), isNot(a));
  });

  test('dealFive starts at hakem in packets of five', () {
    final deck = shuffledDeck(1);
    final deal = dealFive(deck: deck, dealer: Seat.south);
    expect(deal.hakem, Seat.east);
    expect(_codes(deal.east), ['2C', '3C', '4S', 'KS', 'AD']);
    expect(_codes(deal.north), ['8C', 'AH', '8H', '2S', 'TD']);
    expect(deal.south, hasLength(5));
    expect(deal.west, hasLength(5));
    expect(deal.stock, hasLength(32));
    expect(_allCards(deal).toSet(), Card.deck.toSet());
  });

  test('dealRest appends eight more from hakem and empties stock', () {
    final deck = shuffledDeck(1);
    final five = dealFive(deck: deck, dealer: Seat.west);
    final full = dealRest(five);
    expect(full.hakem, Seat.south);
    expect(full.south, [...five.south, ...deck.sublist(20, 28)]);
    expect(full.south, hasLength(13));
    expect(full.east, hasLength(13));
    expect(full.north, hasLength(13));
    expect(full.west, hasLength(13));
    expect(full.stock, isEmpty);
    expect(_allCards(full).toSet(), Card.deck.toSet());
  });

  test('dealRest rejects a completed or short deal', () {
    final five = dealFive(deck: shuffledDeck(1), dealer: Seat.north);
    expect(() => dealRest(dealRest(five)), throwsStateError);
    expect(
      () => dealFive(deck: Card.deck.take(10).toList(), dealer: Seat.south),
      throwsArgumentError,
    );
  });
}

List<String> _codes(List<Card> cards) {
  return [for (final card in cards) card.code];
}

List<Card> _allCards(Deal deal) {
  return [
    ...deal.north,
    ...deal.east,
    ...deal.south,
    ...deal.west,
    ...deal.stock,
  ];
}
