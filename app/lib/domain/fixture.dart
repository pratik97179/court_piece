import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/deal.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/reduce.dart';
import 'package:court_piece/domain/seat.dart';

/// Seeded deal plus first-legal-card play, as a JSON map.
Map<String, Object> buildDealFixture({
  required int seed,
  required Seat dealer,
}) {
  var state = GameState.match(seed: seed, dealer: dealer);
  final five = _handsJson(state.deal);
  final stock = _codes(state.deal.stock);
  final hakem = state.deal.hakem;
  final trump = state.deal.hand(hakem).first.suit;
  state = (reduce(state, CallTrump(seat: hakem, suit: trump)) as Accept).state;
  final thirteen = _handsJson(state.deal);
  final plays = <Map<String, String>>[];
  while (state.phase is Playing) {
    final seat = state.toAct;
    final card = legalPlays(state, seat).first;
    plays.add({'seat': seat.name, 'card': card.code});
    state = (reduce(state, PlayCard(seat: seat, card: card)) as Accept).state;
  }
  final over = state.phase as DealOver;
  var northSouthTricks = 0;
  var eastWestTricks = 0;
  final tricks = [
    for (final trick in state.completed)
      {
        'winner': trick.winner.name,
        'cards': [for (final play in trick.plays) play.card.code],
      },
  ];
  for (final trick in state.completed) {
    if (trick.winner.team == Team.northSouth) {
      northSouthTricks += 1;
    } else {
      eastWestTricks += 1;
    }
  }
  return {
    'seed': seed,
    'dealer': dealer.name,
    'hakem': hakem.name,
    'deck': _codes(shuffledDeck(seed)),
    'five': five,
    'stock': stock,
    'trump': trump.letter,
    'thirteen': thirteen,
    'plays': plays,
    'tricks': tricks,
    'winner': over.winner.name,
    'court': over.court,
    'northSouthTricks': northSouthTricks,
    'eastWestTricks': eastWestTricks,
  };
}

Map<String, List<String>> _handsJson(Deal deal) {
  return {
    'north': _codes(deal.north),
    'east': _codes(deal.east),
    'south': _codes(deal.south),
    'west': _codes(deal.west),
  };
}

List<String> _codes(List<Card> cards) {
  return [for (final card in cards) card.code];
}
