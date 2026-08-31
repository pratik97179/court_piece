import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/seat.dart';

/// Hands and remaining stock after a deal step.
final class Deal {
  const Deal._({
    required this.dealer,
    required this.hakem,
    required this.north,
    required this.east,
    required this.south,
    required this.west,
    required this.stock,
  });

  final Seat dealer;
  final Seat hakem;
  final List<Card> north;
  final List<Card> east;
  final List<Card> south;
  final List<Card> west;
  final List<Card> stock;

  List<Card> hand(Seat seat) {
    return switch (seat) {
      Seat.north => north,
      Seat.east => east,
      Seat.south => south,
      Seat.west => west,
    };
  }

  Deal without(Seat seat, Card card) {
    final next = List<Card>.of(hand(seat));
    if (!next.remove(card)) {
      throw StateError('card not in hand');
    }
    return Deal._(
      dealer: dealer,
      hakem: hakem,
      north: seat == Seat.north ? List<Card>.unmodifiable(next) : north,
      east: seat == Seat.east ? List<Card>.unmodifiable(next) : east,
      south: seat == Seat.south ? List<Card>.unmodifiable(next) : south,
      west: seat == Seat.west ? List<Card>.unmodifiable(next) : west,
      stock: stock,
    );
  }
}

/// Deterministic Fisher-Yates. Same seed, same order.
List<Card> shuffledDeck(int seed) {
  final cards = List<Card>.of(Card.deck);
  final rng = _Rng(seed);
  for (var i = cards.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final swap = cards[i];
    cards[i] = cards[j];
    cards[j] = swap;
  }
  return List<Card>.unmodifiable(cards);
}

/// Five cards each, starting at hakem, rest in [Deal.stock].
Deal dealFive({required List<Card> deck, required Seat dealer}) {
  _requireFullDeck(deck);
  return _dealPackets(deck: deck, dealer: dealer, packet: 5);
}

/// Eight more cards each from [Deal.stock], starting at hakem.
Deal dealRest(Deal deal) {
  if (deal.stock.length != 32) {
    throw StateError('dealRest expects 32 cards in stock');
  }
  for (final seat in Seat.values) {
    if (deal.hand(seat).length != 5) {
      throw StateError('dealRest expects 5 cards per hand');
    }
  }
  final rest = _dealPackets(deck: deal.stock, dealer: deal.dealer, packet: 8);
  return Deal._(
    dealer: deal.dealer,
    hakem: deal.hakem,
    north: List<Card>.unmodifiable([...deal.north, ...rest.north]),
    east: List<Card>.unmodifiable([...deal.east, ...rest.east]),
    south: List<Card>.unmodifiable([...deal.south, ...rest.south]),
    west: List<Card>.unmodifiable([...deal.west, ...rest.west]),
    stock: rest.stock,
  );
}

Deal _dealPackets({
  required List<Card> deck,
  required Seat dealer,
  required int packet,
}) {
  final hakem = dealer.next;
  var offset = 0;
  List<Card> take() {
    final slice = deck.sublist(offset, offset + packet);
    offset += packet;
    return List<Card>.unmodifiable(slice);
  }

  final assigned = <Seat, List<Card>>{};
  var seat = hakem;
  for (var i = 0; i < Seat.values.length; i++) {
    assigned[seat] = take();
    seat = seat.next;
  }
  return Deal._(
    dealer: dealer,
    hakem: hakem,
    north: assigned[Seat.north]!,
    east: assigned[Seat.east]!,
    south: assigned[Seat.south]!,
    west: assigned[Seat.west]!,
    stock: List<Card>.unmodifiable(deck.sublist(offset)),
  );
}

void _requireFullDeck(List<Card> deck) {
  if (deck.length != 52 || deck.toSet().length != 52) {
    throw ArgumentError.value(deck, 'deck', 'must be 52 unique cards');
  }
}

/// Numerical Recipes 32-bit LCG.
final class _Rng {
  _Rng(int seed) : _state = seed.toUnsigned(32);

  int _state;

  int nextUint32() {
    _state = (_state * 1664525 + 1013904223).toUnsigned(32);
    return _state;
  }

  int nextInt(int n) {
    final bound = 0x100000000;
    final threshold = bound - (bound % n);
    while (true) {
      final r = nextUint32();
      if (r < threshold) {
        return r % n;
      }
    }
  }
}
