import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/infrastructure/svg_card_art.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const art = SvgCardArt();

  test('maps every face to a unique existing asset', () async {
    expect(CardArtId.deck, hasLength(52));

    final paths = <String>{};
    for (final id in CardArtId.deck) {
      final path = art.faceAsset(id);
      expect(paths.add(path), isTrue);
      await rootBundle.load(path);
    }
  });

  test('uses the SVG file name for ace of spades', () {
    expect(
      art.faceAsset(const CardArtId(rank: ArtRank.ace, suit: ArtSuit.spades)),
      'assets/cards/ace_of_spades.svg',
    );
  });
}
