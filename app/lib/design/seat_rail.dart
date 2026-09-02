import 'dart:math' as math;

import 'package:court_piece/design/pivot_hand.dart';
import 'package:court_piece/design/table.dart';
import 'package:flutter/material.dart';

/// Local hand: cards stack on one pivot, then fan by ±π/25 from an upright center.
class SeatRail extends StatelessWidget {
  const SeatRail({super.key, required this.cards, this.scale = CardScale.hand});

  final List<Widget> cards;
  final CardScale scale;

  /// Angle step between neighboring cards away from the upright center.
  static const step = PivotHand.step;

  /// Max horizontal span of the fanned hand, in card widths.
  static const spreadWidths = PivotHand.spreadWidths;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    final module = TableScope.maybeOf(context)!;
    final cardWidth = module.widthFor(scale);
    final layout = PivotHand.layout(count: cards.length, cardWidth: cardWidth);
    final maxWidth = cardWidth * spreadWidths;
    // Cap only: never enlarge cards to fill the max spread.
    final fit = cards.length <= 1 || layout.width <= 0
        ? 1.0
        : math.min(1.0, maxWidth / layout.width);
    final fan = SizedBox(
      width: layout.width,
      height: layout.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final i in layout.paintOrder)
            Positioned(
              left: layout.originLeft,
              top: layout.originTop,
              width: cardWidth,
              height: layout.cardHeight,
              child: Transform.rotate(
                angle: layout.angles[i],
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: PivotHand.preRotateShift,
                  child: cards[i],
                ),
              ),
            ),
        ],
      ),
    );
    if (fit >= 1.0) {
      return fan;
    }
    return SizedBox(
      width: layout.width * fit,
      height: layout.height * fit,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.scale(
          scale: fit,
          alignment: Alignment.bottomCenter,
          child: fan,
        ),
      ),
    );
  }
}
