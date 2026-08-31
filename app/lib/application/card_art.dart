enum ArtSuit { clubs, diamonds, hearts, spades }

enum ArtRank {
  ace,
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
}

final class CardArtId {
  const CardArtId({required this.rank, required this.suit});

  final ArtRank rank;
  final ArtSuit suit;

  static final List<CardArtId> deck = [
    for (final suit in ArtSuit.values)
      for (final rank in ArtRank.values) CardArtId(rank: rank, suit: suit),
  ];

  @override
  bool operator ==(Object other) {
    return other is CardArtId && rank == other.rank && suit == other.suit;
  }

  @override
  int get hashCode => Object.hash(rank, suit);
}

/// Resolves a card face to an asset path. Callers never pass a file name.
abstract interface class CardArt {
  String faceAsset(CardArtId id);
}
