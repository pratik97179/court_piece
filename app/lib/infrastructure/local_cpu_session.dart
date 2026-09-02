import 'dart:async';

import 'package:court_piece/application/cpu_strategy.dart';
import 'package:court_piece/application/game_session.dart';
import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/reduce.dart';
import 'package:court_piece/domain/seat.dart';

/// South is human. North, east, and west use [CpuStrategy].
final class LocalCpuSession implements PausableGameSession {
  LocalCpuSession({
    required CpuStrategy cpu,
    required int seed,
    Seat? dealer,
    this.cpuPause = Duration.zero,
  }) : _cpu = cpu {
    _state = GameState.match(seed: seed, dealer: dealer);
    _advanceCpus();
  }

  static const _human = Seat.south;

  final Duration cpuPause;
  final CpuStrategy _cpu;
  late GameState _state;
  late TableView _view;
  final _listeners = <void Function()>[];
  final _events = <TableEvent>[];
  var _disposed = false;
  var _actingPaused = false;
  Timer? _cpuTimer;

  @override
  TableView get view => _view;

  @override
  void submit(PlayerIntent intent) {
    if (_disposed) {
      return;
    }
    _cpuTimer?.cancel();
    final mapped = switch (intent) {
      CallTrumpIntent(:final suit) => CallTrump(seat: _human, suit: suit),
      PlayCardIntent(:final card) => PlayCard(seat: _human, card: card),
      StartDealIntent() => const StartDeal(),
    };
    if (!_apply(mapped)) {
      _notify();
      return;
    }
    _advanceCpus();
    _notify();
  }

  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  @override
  List<TableEvent> takeEvents() {
    final out = List<TableEvent>.of(_events);
    _events.clear();
    return out;
  }

  @override
  void setActingPaused(bool paused) {
    if (_actingPaused == paused) {
      return;
    }
    _actingPaused = paused;
    if (!paused) {
      _advanceCpus();
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cpuTimer?.cancel();
    _listeners.clear();
    _events.clear();
  }

  void _advanceCpus() {
    if (!_actingPaused) {
      _runCpus(limit: cpuPause == Duration.zero ? 64 : 1);
    }
    _view = _toView(_state);
    if (_actingPaused) {
      return;
    }
    if (cpuPause > Duration.zero && _cpuShouldAct()) {
      _cpuTimer?.cancel();
      _cpuTimer = Timer(cpuPause, () {
        if (_disposed) {
          return;
        }
        _advanceCpus();
        _notify();
      });
    }
  }

  bool _cpuShouldAct() {
    final phase = _state.phase;
    if (phase is WaitingTrump && _state.toAct != _human) {
      return true;
    }
    return phase is Playing && _state.toAct != _human;
  }

  void _runCpus({required int limit}) {
    var guard = 0;
    while (guard++ < limit && _cpuShouldAct()) {
      final phase = _state.phase;
      if (phase is WaitingTrump) {
        final suit = _cpu.pickTrump(_state.deal.hand(_state.toAct));
        if (!_apply(CallTrump(seat: _state.toAct, suit: suit))) {
          break;
        }
        continue;
      }
      if (phase is Playing) {
        final card = _cpu.pickCard(
          legal: legalPlays(_state, _state.toAct),
          trump: phase.trump,
          trick: phase.trick,
        );
        if (!_apply(PlayCard(seat: _state.toAct, card: card))) {
          break;
        }
      }
    }
  }

  bool _apply(Intent intent) {
    final before = _state;
    switch (reduce(_state, intent)) {
      case Accept(:final state):
        _state = state;
        _emitTrickWon(before, state);
        _emitPhaseEvents(before.phase, state.phase);
        return true;
      case Reject(:final reason):
        _events.add(TableRejected(_toReject(reason)));
        return false;
    }
  }

  void _emitTrickWon(GameState before, GameState after) {
    if (after.completed.length <= before.completed.length) {
      return;
    }
    final trick = after.completed.last;
    _events.add(
      TableTrickWon(
        winner: trick.winner,
        plays: [
          for (final play in trick.plays)
            TablePlay(seat: play.seat, card: play.card),
        ],
      ),
    );
  }

  void _emitPhaseEvents(Phase before, Phase after) {
    if (before is DealOver || before is MatchOver) {
      return;
    }
    if (after is DealOver) {
      _events.add(TableDealOver(winner: after.winner, court: after.court));
    } else if (after is MatchOver) {
      _events.add(TableMatchOver(after.winner));
    }
  }

  void _notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}

TableReject _toReject(RejectReason reason) {
  return switch (reason) {
    RejectReason.wrongPhase => TableReject.wrongPhase,
    RejectReason.notYourTurn => TableReject.notYourTurn,
    RejectReason.cardNotHeld => TableReject.cardNotHeld,
    RejectReason.mustFollowSuit => TableReject.mustFollowSuit,
  };
}

TableView _toView(GameState state) {
  final phase = state.phase;
  var northSouthTricks = 0;
  var eastWestTricks = 0;
  for (final trick in state.completed) {
    if (trick.winner.team == Team.northSouth) {
      northSouthTricks += 1;
    } else {
      eastWestTricks += 1;
    }
  }
  return TableView(
    phase: switch (phase) {
      WaitingTrump() => TablePhase.waitingTrump,
      Playing() => TablePhase.playing,
      DealOver() => TablePhase.dealOver,
      MatchOver() => TablePhase.matchOver,
    },
    toAct: state.toAct,
    hakem: state.deal.hakem,
    dealer: state.deal.dealer,
    trump: switch (phase) {
      Playing(:final trump) => trump,
      DealOver(:final trump) => trump,
      _ => null,
    },
    southHand: List<Card>.unmodifiable(state.deal.south),
    northCount: state.deal.north.length,
    eastCount: state.deal.east.length,
    westCount: state.deal.west.length,
    trick: switch (phase) {
      Playing(:final trick) => [
        for (final play in trick) TablePlay(seat: play.seat, card: play.card),
      ],
      _ => const [],
    },
    northSouthTricks: northSouthTricks,
    eastWestTricks: eastWestTricks,
    northSouthCourts: state.northSouthCourts,
    eastWestCourts: state.eastWestCourts,
    legalSouth: List<Card>.unmodifiable(legalPlays(state, Seat.south)),
    dealWinner: phase is DealOver ? phase.winner : null,
    dealCourt: phase is DealOver && phase.court,
    matchWinner: phase is MatchOver ? phase.winner : null,
  );
}
