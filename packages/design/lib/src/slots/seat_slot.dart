import 'package:flutter/foundation.dart';

import 'card_visual.dart';

class HandFan {
  const HandFan({
    required this.cards,
    required this.onPlay,
  });

  final List<CardVisual> cards;
  final ValueChanged<CardVisual> onPlay;
}

class SeatSlot {
  const SeatSlot._({
    required this.you,
    required this.isTurn,
    this.hand,
    this.count = 0,
    this.label = '',
  });

  factory SeatSlot.you({
    required HandFan hand,
    required bool isTurn,
    String label = '',
  }) {
    return SeatSlot._(you: true, hand: hand, isTurn: isTurn, label: label);
  }

  factory SeatSlot.opponent({
    required int count,
    required bool isTurn,
    String label = '',
  }) {
    return SeatSlot._(you: false, count: count, isTurn: isTurn, label: label);
  }

  final bool you;
  final bool isTurn;
  final HandFan? hand;
  final int count;
  final String label;
}
