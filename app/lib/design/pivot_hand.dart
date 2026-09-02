import 'dart:math' as math;

import 'package:court_piece/design/playing_card.dart';
import 'package:flutter/material.dart';

/// Stacked cards that rotate about the upright center card's bottom center.
@immutable
final class PivotHand {
  const PivotHand._({
    required this.width,
    required this.height,
    required this.originLeft,
    required this.originTop,
    required this.cardHeight,
    required this.angles,
    required this.paintOrder,
    required this.centerIndex,
  });

  final double width;
  final double height;
  final double originLeft;
  final double originTop;
  final double cardHeight;
  final List<double> angles;
  final List<int> paintOrder;
  final int centerIndex;

  /// Angle step between neighboring cards away from the upright center.
  static const step = math.pi / 25;

  /// Max horizontal span of the fanned hand, in card widths.
  static const spreadWidths = 6.0;

  /// Shift each card right before rotating about the shared bottom-center pivot.
  static const preRotateShift = Offset(10, 0);

  static PivotHand layout({required int count, required double cardWidth}) {
    if (count <= 0) {
      return const PivotHand._(
        width: 0,
        height: 0,
        originLeft: 0,
        originTop: 0,
        cardHeight: 0,
        angles: [],
        paintOrder: [],
        centerIndex: 0,
      );
    }
    final cardHeight = cardWidth / PlayingCard.aspect;
    final center = count ~/ 2;
    final angles = [
      for (var i = 0; i < count; i++) angleAt(index: i, center: center),
    ];
    final pivot = Offset(cardWidth / 2, cardHeight);
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final angle in angles) {
      for (final corner in _corners(cardWidth, cardHeight)) {
        final shifted = corner + preRotateShift;
        final point = _rotateAround(shifted, pivot, angle);
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }
    }
    // Later in the list paints above. Rightmost is on top; z falls toward the left.
    final paintOrder = [for (var i = 0; i < count; i++) i];
    return PivotHand._(
      width: maxX - minX,
      height: maxY - minY,
      originLeft: -minX,
      originTop: -minY,
      cardHeight: cardHeight,
      angles: angles,
      paintOrder: paintOrder,
      centerIndex: center,
    );
  }

  /// Upright center stays at 0. Left of center steps by -π/25, right by +π/25.
  static double angleAt({required int index, required int center}) {
    if (index == center) {
      return 0;
    }
    if (index < center) {
      return -(center - index) * step;
    }
    return (index - center) * step;
  }

  static List<Offset> _corners(double width, double height) {
    return [
      Offset.zero,
      Offset(width, 0),
      Offset(width, height),
      Offset(0, height),
    ];
  }

  static Offset _rotateAround(Offset point, Offset pivot, double angle) {
    if (angle == 0) {
      return point;
    }
    final s = math.sin(angle);
    final c = math.cos(angle);
    final dx = point.dx - pivot.dx;
    final dy = point.dy - pivot.dy;
    return Offset(pivot.dx + dx * c - dy * s, pivot.dy + dx * s + dy * c);
  }
}
