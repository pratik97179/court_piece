import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';

/// Picks a trump and a legal card. Callers pass already-legal cards.
abstract interface class CpuStrategy {
  Suit pickTrump(List<Card> hand);

  Card pickCard({
    required List<Card> legal,
    required Suit trump,
    required List<Play> trick,
  });
}
