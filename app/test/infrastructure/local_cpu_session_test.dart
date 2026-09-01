import 'package:court_piece/application/cpu_strategy.dart';
import 'package:court_piece/application/game_session.dart';
import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/game.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:court_piece/infrastructure/local_cpu_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('waits on south when south is hakem', () {
    final session = LocalCpuSession(
      cpu: _ScriptedCpu(),
      seed: 1,
      dealer: Seat.west,
    );
    expect(session.view.phase, TablePhase.waitingTrump);
    expect(session.view.hakem, Seat.south);
    expect(session.view.toAct, Seat.south);
    expect(session.view.southHand, hasLength(5));
    expect(session.view.northCount, 5);
    expect(session.view.eastCount, 5);
    expect(session.view.westCount, 5);
    expect(session.view.trump, isNull);
    session.dispose();
  });

  test('cpu hakem names trump and plays until south', () {
    final session = LocalCpuSession(
      cpu: _ScriptedCpu(trump: Suit.hearts),
      seed: 1,
      dealer: Seat.south,
    );
    expect(session.view.phase, TablePhase.playing);
    expect(session.view.trump, Suit.hearts);
    expect(session.view.hakem, Seat.east);
    expect(session.view.toAct, Seat.south);
    expect(session.view.trick, hasLength(3));
    expect(session.view.southHand, hasLength(13));
    expect(session.view.eastCount, 12);
    expect(session.view.legalSouth, isNotEmpty);
    session.dispose();
  });

  test('south play updates the view and cpus continue', () {
    final session = LocalCpuSession(
      cpu: _ScriptedCpu(trump: Suit.hearts),
      seed: 1,
      dealer: Seat.south,
    );
    final card = session.view.legalSouth.first;
    var ticks = 0;
    session.addListener(() => ticks += 1);
    session.submit(PlayCardIntent(card));
    expect(ticks, 1);
    expect(session.view.southHand.contains(card), isFalse);
    expect(session.view.phase, TablePhase.playing);
    expect(session.view.toAct, Seat.south);
    expect(
      session.view.northSouthTricks + session.view.eastWestTricks,
      greaterThanOrEqualTo(1),
    );
    session.dispose();
  });

  test('illegal submit keeps the view and emits TableRejected', () {
    final session = LocalCpuSession(
      cpu: _ScriptedCpu(),
      seed: 1,
      dealer: Seat.west,
    );
    final before = session.view;
    var ticks = 0;
    session.addListener(() => ticks += 1);
    session.submit(PlayCardIntent(before.southHand.first));
    expect(ticks, 1);
    expect(session.view.phase, before.phase);
    expect(session.view.toAct, before.toAct);
    expect(session.view.southHand, before.southHand);
    expect(session.takeEvents(), [const TableRejected(TableReject.wrongPhase)]);
    expect(session.takeEvents(), isEmpty);
    session.dispose();
  });

  test('first-legal play reaches deal over, then StartDeal begins the next', () {
    final session = LocalCpuSession(
      cpu: _ScriptedCpu(),
      seed: 1,
      dealer: Seat.west,
    );
    _playUntilIdle(session);
    expect(session.view.phase, TablePhase.dealOver);
    expect(session.view.dealWinner, isNotNull);
    final events = session.takeEvents();
    expect(events.whereType<TableDealOver>(), hasLength(1));
    session.submit(const StartDealIntent());
    expect(
      session.view.phase,
      anyOf(TablePhase.waitingTrump, TablePhase.playing),
    );
    expect(session.view.dealWinner, isNull);
    session.dispose();
  });

  test('dispose ignores later submits', () {
    final session = LocalCpuSession(
      cpu: _ScriptedCpu(),
      seed: 1,
      dealer: Seat.west,
    );
    var ticks = 0;
    session.addListener(() => ticks += 1);
    session.dispose();
    session.submit(CallTrumpIntent(session.view.southHand.first.suit));
    expect(ticks, 0);
  });
}

void _playUntilIdle(GameSession session) {
  var guard = 0;
  while (guard++ < 80) {
    final view = session.view;
    if (view.phase == TablePhase.dealOver ||
        view.phase == TablePhase.matchOver) {
      return;
    }
    if (view.phase == TablePhase.waitingTrump && view.toAct == Seat.south) {
      session.submit(CallTrumpIntent(view.southHand.first.suit));
      continue;
    }
    if (view.legalSouth.isNotEmpty) {
      session.submit(PlayCardIntent(view.legalSouth.first));
      continue;
    }
    fail('session stuck at ${view.phase} toAct ${view.toAct}');
  }
  fail('deal did not end');
}

final class _ScriptedCpu implements CpuStrategy {
  _ScriptedCpu({this.trump = Suit.clubs});

  final Suit trump;

  @override
  Suit pickTrump(List<Card> hand) => trump;

  @override
  Card pickCard({
    required List<Card> legal,
    required Suit trump,
    required List<Play> trick,
  }) {
    return legal.first;
  }
}
