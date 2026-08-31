import 'action.dart';
import 'card.dart';
import 'phase.dart';
import 'seat.dart';
import 'state.dart';
import 'apply.dart';

/// Seat-scoped public view. Other hands never appear here.
class MatchView {
  const MatchView({
    required this.you,
    required this.phase,
    required this.hand,
    required this.allowedActions,
    required this.trump,
    required this.trick,
    required this.handCounts,
    required this.tricks,
    required this.courts,
    required this.turn,
    required this.dealer,
    required this.hakem,
    required this.targetCourts,
  });

  final Seat you;
  final Phase phase;
  final List<Card> hand;
  final List<Action> allowedActions;
  final Suit? trump;
  final List<PlayedCard> trick;
  final Map<Seat, int> handCounts;
  final Map<Team, int> tricks;
  final Map<Team, int> courts;
  final Seat turn;
  final Seat dealer;
  final Seat hakem;
  final int targetCourts;

  Team get yourTeam => you.team;

  bool get canAct => allowedActions.isNotEmpty;
}

MatchView viewFor(GameState state, Seat seat) {
  final showHand = state.phase is AwaitingTrump ? seat == state.hakem : true;
  return MatchView(
    you: seat,
    phase: state.phase,
    hand: showHand
        ? List<Card>.from(state.hands[seat] ?? const [])
        : const [],
    allowedActions: legalActions(state, seat),
    trump: state.trump,
    trick: List<PlayedCard>.from(state.trick),
    handCounts: {
      for (final s in Seat.values) s: (state.hands[s] ?? const []).length,
    },
    tricks: Map<Team, int>.from(state.tricks),
    courts: Map<Team, int>.from(state.courts),
    turn: state.turn,
    dealer: state.dealer,
    hakem: state.hakem,
    targetCourts: state.targetCourts,
  );
}
