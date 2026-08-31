import 'package:court_piece/design/playing_card.dart';
import 'package:court_piece/design/table.dart';
import 'package:flutter/material.dart';

/// Overlapping cards along one seat. The local hand gets a shallow fan.
class SeatRail extends StatelessWidget {
  const SeatRail({
    super.key,
    required this.cards,
    this.axis = Axis.horizontal,
    this.scale = CardScale.opponent,
  });

  final List<Widget> cards;
  final Axis axis;
  final CardScale scale;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    final module = TableScope.maybeOf(context);
    final width = module?.widthFor(scale) ?? 56;
    final height = width / PlayingCard.aspect;
    final along = axis == Axis.horizontal ? width : height;
    final overlap = module?.overlapFor(scale) ?? 0.55;
    final fan = scale == CardScale.hand && axis == Axis.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxAlong = axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final step = _step(
          count: cards.length,
          along: along,
          maxAlong: maxAlong,
          overlap: overlap,
        );
        final extent = along + (cards.length - 1) * step;
        final arc = fan ? height * 0.1 : 0.0;
        final mid = (cards.length - 1) / 2;
        return SizedBox(
          width: axis == Axis.horizontal ? extent : width,
          height: axis == Axis.horizontal ? height + arc : extent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < cards.length; i++)
                Positioned(
                  left: axis == Axis.horizontal ? i * step : 0,
                  top: axis == Axis.vertical ? i * step : _arcDrop(i, mid, arc),
                  child: _tilt(i, mid, fan, cards[i]),
                ),
            ],
          ),
        );
      },
    );
  }

  static double _arcDrop(int index, double mid, double arc) {
    if (arc == 0 || mid == 0) {
      return 0;
    }
    final t = (index - mid) / mid;
    return t.abs() * arc;
  }

  static Widget _tilt(int index, double mid, bool fan, Widget child) {
    if (!fan || mid == 0) {
      return child;
    }
    final t = (index - mid) / mid;
    return Transform.rotate(
      angle: t * 0.055,
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }

  static double _step({
    required int count,
    required double along,
    required double maxAlong,
    required double overlap,
  }) {
    if (count < 2) {
      return 0;
    }
    final available = (maxAlong - along) / (count - 1);
    final preferred = along * (1 - overlap);
    final loosest = along * 0.78;
    final tightest = along * 0.24;
    if (available.isInfinite || available.isNaN) {
      return preferred;
    }
    if (available < preferred) {
      return available.clamp(tightest, preferred);
    }
    return available.clamp(preferred, loosest);
  }
}
