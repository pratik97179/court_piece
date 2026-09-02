import 'dart:math' as math;

import 'package:court_piece/design/motion.dart';
import 'package:court_piece/design/playing_card.dart';
import 'package:flutter/material.dart';

/// One card in a fan before the bounding-box shift is applied.
@immutable
final class FanSlot {
  const FanSlot({required this.left, required this.top, required this.angle});

  final double left;
  final double top;
  final double angle;
}

/// Fan curve, overlap, and optional whole-hand rotation for a seat.
@immutable
final class FanSpec {
  const FanSpec({
    required this.cardWidth,
    required this.overlap,
    required this.arc,
    required this.tilt,
    this.rotation = 0,
    this.maxAlong = double.infinity,
    this.pivot = Alignment.bottomCenter,
  });

  final double cardWidth;
  final double overlap;
  final double arc;
  final double tilt;
  final double rotation;
  final double maxAlong;
  final Alignment pivot;

  double get cardHeight => cardWidth / PlayingCard.aspect;
}

/// Bounding box for a fan, including seat rotation.
@immutable
final class FanBounds {
  const FanBounds({
    required this.width,
    required this.height,
    required this.shiftX,
    required this.shiftY,
    required this.fanPivot,
    required this.localWidth,
    required this.localHeight,
  });

  final double width;
  final double height;
  final double shiftX;
  final double shiftY;
  final Offset fanPivot;
  final double localWidth;
  final double localHeight;
}

/// Layout math shared by opponent backs and the local hand.
abstract final class FanLayout {
  static List<FanSlot> slots({required int count, required FanSpec spec}) {
    if (count <= 0) {
      return const [];
    }
    final w = spec.cardWidth;
    final h = spec.cardHeight;
    final mid = (count - 1) / 2;
    final preferred = w * (1 - spec.overlap);
    var step = preferred;
    if (count > 1 && spec.maxAlong.isFinite) {
      final available = (spec.maxAlong - w) / (count - 1);
      step = available < preferred ? math.max(0.0, available) : preferred;
    }
    final arcPx = h * spec.arc;
    return [
      for (var i = 0; i < count; i++)
        FanSlot(
          left: i * step,
          top: _arcDrop(i, mid, arcPx),
          angle: mid == 0 ? 0 : ((i - mid) / mid) * spec.tilt,
        ),
    ];
  }

  static FanBounds measure({required int count, required FanSpec spec}) {
    final layout = slots(count: count, spec: spec);
    if (layout.isEmpty) {
      return const FanBounds(
        width: 0,
        height: 0,
        shiftX: 0,
        shiftY: 0,
        fanPivot: Offset.zero,
        localWidth: 0,
        localHeight: 0,
      );
    }
    final local = _localBounds(layout, spec);
    final pivot = Offset(local.width / 2, local.height);
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final slot in layout) {
      for (final corner in _tiltedCorners(slot: slot, spec: spec)) {
        final point = spec.rotation == 0
            ? corner
            : _rotateAround(corner, pivot, spec.rotation);
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }
    }
    return FanBounds(
      width: maxX - minX,
      height: maxY - minY,
      shiftX: -minX,
      shiftY: -minY,
      fanPivot: pivot,
      localWidth: local.width,
      localHeight: local.height,
    );
  }

  static ({double left, double top}) frameOrigin({
    required FanSlot slot,
    required FanSpec spec,
    required FanBounds bounds,
  }) {
    var minX = double.infinity;
    var minY = double.infinity;
    for (final corner in _tiltedCorners(slot: slot, spec: spec)) {
      final point = spec.rotation == 0
          ? corner
          : _rotateAround(corner, bounds.fanPivot, spec.rotation);
      minX = math.min(minX, point.dx);
      minY = math.min(minY, point.dy);
    }
    return (left: minX + bounds.shiftX, top: minY + bounds.shiftY);
  }

  static ({double width, double height}) _localBounds(
    List<FanSlot> layout,
    FanSpec spec,
  ) {
    var maxRight = 0.0;
    var maxBottom = 0.0;
    for (final slot in layout) {
      for (final corner in _tiltedCorners(slot: slot, spec: spec)) {
        maxRight = math.max(maxRight, corner.dx);
        maxBottom = math.max(maxBottom, corner.dy);
      }
    }
    return (width: maxRight, height: maxBottom);
  }

  static double _arcDrop(int index, double mid, double arc) {
    if (arc == 0 || mid == 0) {
      return 0;
    }
    final t = (index - mid) / mid;
    return t.abs() * arc;
  }

  static List<Offset> _tiltedCorners({
    required FanSlot slot,
    required FanSpec spec,
  }) {
    final w = spec.cardWidth;
    final h = spec.cardHeight;
    final pivot = Offset(
      slot.left + w * (spec.pivot.x + 1) / 2,
      slot.top + h * (spec.pivot.y + 1) / 2,
    );
    final corners = [
      Offset(slot.left, slot.top),
      Offset(slot.left + w, slot.top),
      Offset(slot.left + w, slot.top + h),
      Offset(slot.left, slot.top + h),
    ];
    return [
      for (final corner in corners) _rotateAround(corner, pivot, slot.angle),
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

/// Overlapping cards in a shallow arc, like a hand holding them.
class CardFan extends StatelessWidget {
  const CardFan({
    super.key,
    required this.spec,
    required this.count,
    required this.cardBuilder,
  });

  final FanSpec spec;
  final int count;
  final Widget Function(int index) cardBuilder;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    final layout = FanLayout.slots(count: count, spec: spec);
    final bounds = FanLayout.measure(count: count, spec: spec);
    return SizedBox(
      width: bounds.width,
      height: bounds.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(bounds.shiftX, bounds.shiftY),
            child: Transform.rotate(
              angle: spec.rotation,
              origin: bounds.fanPivot,
              child: SizedBox(
                width: bounds.localWidth,
                height: bounds.localHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < count; i++)
                      _FanCard(
                        slot: layout[i],
                        spec: spec,
                        animate: CourtMotion.live(context),
                        child: cardBuilder(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FanCard extends StatelessWidget {
  const _FanCard({
    required this.slot,
    required this.spec,
    required this.animate,
    required this.child,
  });

  final FanSlot slot;
  final FanSpec spec;
  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: animate ? CourtMotion.crossfade : Duration.zero,
      curve: Curves.easeOutCubic,
      left: slot.left,
      top: slot.top,
      width: spec.cardWidth,
      height: spec.cardHeight,
      child: Transform.rotate(
        angle: slot.angle,
        alignment: spec.pivot,
        child: child,
      ),
    );
  }
}
