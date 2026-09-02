import 'package:court_piece/application/card_art.dart';

/// Resolves a face to a PNG-cards asset. Faces are the non-2 set, no jokers.
final class PngCardArt implements CardArt {
  const PngCardArt();

  static const prefix = 'assets/cards';

  @override
  String faceAsset(CardArtId id) {
    return '$prefix/${_rankFile(id.rank)}_of_${id.suit.name}.png';
  }

  static String _rankFile(ArtRank rank) {
    return switch (rank) {
      ArtRank.ace => 'ace',
      ArtRank.two => '2',
      ArtRank.three => '3',
      ArtRank.four => '4',
      ArtRank.five => '5',
      ArtRank.six => '6',
      ArtRank.seven => '7',
      ArtRank.eight => '8',
      ArtRank.nine => '9',
      ArtRank.ten => '10',
      ArtRank.jack => 'jack',
      ArtRank.queen => 'queen',
      ArtRank.king => 'king',
    };
  }
}
