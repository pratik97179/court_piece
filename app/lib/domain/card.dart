/// French suit.
enum Suit {
  clubs('C'),
  diamonds('D'),
  hearts('H'),
  spades('S');

  const Suit(this.letter);

  final String letter;

  static Suit parse(String letter) {
    for (final suit in Suit.values) {
      if (suit.letter == letter) {
        return suit;
      }
    }
    throw FormatException('unknown suit', letter);
  }
}

/// Rank of a [Card].
enum Rank {
  ace('A'),
  two('2'),
  three('3'),
  four('4'),
  five('5'),
  six('6'),
  seven('7'),
  eight('8'),
  nine('9'),
  ten('T'),
  jack('J'),
  queen('Q'),
  king('K');

  const Rank(this.letter);

  final String letter;

  int get power => switch (this) {
    ace => 14,
    king => 13,
    queen => 12,
    jack => 11,
    ten => 10,
    nine => 9,
    eight => 8,
    seven => 7,
    six => 6,
    five => 5,
    four => 4,
    three => 3,
    two => 2,
  };

  static Rank parse(String letter) {
    for (final rank in Rank.values) {
      if (rank.letter == letter) {
        return rank;
      }
    }
    throw FormatException('unknown rank', letter);
  }
}

/// Immutable playing card. [code] is rank then suit, for example `AS`.
final class Card {
  const Card({required this.rank, required this.suit});

  final Rank rank;
  final Suit suit;

  static final List<Card> deck = [
    for (final suit in Suit.values)
      for (final rank in Rank.values) Card(rank: rank, suit: suit),
  ];

  String get code => '${rank.letter}${suit.letter}';

  factory Card.parse(String code) {
    if (code.length != 2) {
      throw FormatException('card code must be two characters', code);
    }
    return Card(rank: Rank.parse(code[0]), suit: Suit.parse(code[1]));
  }

  @override
  bool operator ==(Object other) {
    return other is Card && rank == other.rank && suit == other.suit;
  }

  @override
  int get hashCode => Object.hash(rank, suit);

  @override
  String toString() => code;
}
