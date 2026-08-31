/// Standard French-suited card.
class Card implements Comparable<Card> {
  const Card(this.suit, this.rank);

  final Suit suit;
  final Rank rank;

  int get code => suit.index * Rank.values.length + rank.index;

  static Card fromCode(int code) {
    final n = Rank.values.length;
    return Card(Suit.values[code ~/ n], Rank.values[code % n]);
  }

  @override
  int compareTo(Card other) {
    final bySuit = suit.index.compareTo(other.suit.index);
    if (bySuit != 0) {
      return bySuit;
    }
    return rank.index.compareTo(other.rank.index);
  }

  @override
  bool operator ==(Object other) =>
      other is Card && other.suit == suit && other.rank == rank;

  @override
  int get hashCode => Object.hash(suit, rank);

  @override
  String toString() => '${rank.name} of ${suit.name}';
}

enum Suit { clubs, diamonds, hearts, spades }

enum Rank {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace,
}

List<Card> fullDeck() => [
  for (final suit in Suit.values)
    for (final rank in Rank.values) Card(suit, rank),
];
