enum VisualSuit { clubs, diamonds, hearts, spades }

enum VisualRank {
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

class CardVisual {
  const CardVisual.face({
    required this.suit,
    required this.rank,
    this.playable = false,
    this.id,
  }) : faceUp = true;

  const CardVisual.back({this.id})
    : suit = VisualSuit.spades,
      rank = VisualRank.ace,
      faceUp = false,
      playable = false;

  final VisualSuit suit;
  final VisualRank rank;
  final bool faceUp;
  final bool playable;
  final String? id;

  int get code => suit.index * VisualRank.values.length + rank.index;

  String get assetPath {
    final rankName = switch (rank) {
      VisualRank.ace => 'ace',
      VisualRank.king => 'king',
      VisualRank.queen => 'queen',
      VisualRank.jack => 'jack',
      VisualRank.ten => '10',
      VisualRank.nine => '9',
      VisualRank.eight => '8',
      VisualRank.seven => '7',
      VisualRank.six => '6',
      VisualRank.five => '5',
      VisualRank.four => '4',
      VisualRank.three => '3',
      VisualRank.two => '2',
    };
    return 'assets/cards/${rankName}_of_${suit.name}.svg';
  }
}

class TrickPlayVisual {
  const TrickPlayVisual({required this.seat, required this.card});

  final SeatVisual seat;
  final CardVisual card;
}

enum SeatVisual { north, east, south, west }
