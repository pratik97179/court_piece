import 'card.dart';
import 'phase.dart';
import 'seat.dart';

class GameState {
  const GameState({
    required this.dealer,
    required this.hakem,
    required this.hands,
    required this.undealt,
    required this.phase,
    required this.turn,
    required this.trump,
    required this.trick,
    required this.trickLeader,
    required this.tricks,
    required this.courts,
    required this.targetCourts,
    required this.seed,
  });

  final Seat dealer;
  final Seat hakem;
  final Map<Seat, List<Card>> hands;
  final List<Card> undealt;
  final Phase phase;
  final Seat turn;
  final Suit? trump;
  final List<PlayedCard> trick;
  final Seat trickLeader;
  final Map<Team, int> tricks;
  final Map<Team, int> courts;
  final int targetCourts;
  final int seed;

  GameState copyWith({
    Seat? dealer,
    Seat? hakem,
    Map<Seat, List<Card>>? hands,
    List<Card>? undealt,
    Phase? phase,
    Seat? turn,
    Suit? trump,
    bool clearTrump = false,
    List<PlayedCard>? trick,
    Seat? trickLeader,
    Map<Team, int>? tricks,
    Map<Team, int>? courts,
    int? targetCourts,
    int? seed,
  }) {
    return GameState(
      dealer: dealer ?? this.dealer,
      hakem: hakem ?? this.hakem,
      hands: hands ?? this.hands,
      undealt: undealt ?? this.undealt,
      phase: phase ?? this.phase,
      turn: turn ?? this.turn,
      trump: clearTrump ? null : (trump ?? this.trump),
      trick: trick ?? this.trick,
      trickLeader: trickLeader ?? this.trickLeader,
      tricks: tricks ?? this.tricks,
      courts: courts ?? this.courts,
      targetCourts: targetCourts ?? this.targetCourts,
      seed: seed ?? this.seed,
    );
  }

  List<Card> handOf(Seat seat) => List<Card>.unmodifiable(hands[seat] ?? const []);

  bool hasSuit(Seat seat, Suit suit) =>
      (hands[seat] ?? const []).any((c) => c.suit == suit);

  Suit? get ledSuit => trick.isEmpty ? null : trick.first.card.suit;
}
