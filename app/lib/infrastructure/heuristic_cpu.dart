import 'package:court_piece/application/cpu_strategy.dart';
import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/reduce.dart';

/// Longest suit for trump. Cheap winners, otherwise lowest card.
final class HeuristicCpu implements CpuStrategy {
  const HeuristicCpu();

  @override
  Suit pickTrump(List<Card> hand) {
    var best = Suit.clubs;
    var bestCount = -1;
    var bestPower = -1;
    for (final suit in Suit.values) {
      var count = 0;
      var power = 0;
      for (final card in hand) {
        if (card.suit == suit) {
          count += 1;
          power += card.rank.power;
        }
      }
      if (count > bestCount || (count == bestCount && power > bestPower)) {
        best = suit;
        bestCount = count;
        bestPower = power;
      }
    }
    return best;
  }

  @override
  Card pickCard({
    required List<Card> legal,
    required Suit trump,
    required List<Play> trick,
  }) {
    if (legal.length == 1) {
      return legal.first;
    }
    if (trick.isEmpty) {
      final side = [
        for (final card in legal)
          if (card.suit != trump) card,
      ];
      return _lowest(side.isEmpty ? legal : side);
    }
    final lead = trick.first.card.suit;
    final winning = trickWinner(trick, trump);
    final top = trick.firstWhere((play) => play.seat == winning).card;
    final winners = [
      for (final card in legal)
        if (beats(card, top, lead: lead, trump: trump)) card,
    ];
    if (winners.isNotEmpty) {
      return _lowest(winners);
    }
    return _lowest(legal);
  }

  static Card _lowest(List<Card> cards) {
    return cards.reduce((best, card) {
      if (card.rank.power != best.rank.power) {
        return card.rank.power < best.rank.power ? card : best;
      }
      return card.suit.index < best.suit.index ? card : best;
    });
  }
}
