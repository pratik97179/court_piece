import 'package:court_piece/design/card_fan.dart';
import 'package:court_piece/design/table.dart';
import 'package:flutter/material.dart';

/// Local player's hand as a held fan. Mobile and desktop use different curves.
class SeatRail extends StatelessWidget {
  const SeatRail({super.key, required this.cards, this.scale = CardScale.hand});

  final List<Widget> cards;
  final CardScale scale;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    final module = TableScope.maybeOf(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxAlong = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : module.handFanAlong;
        var overlap = module.handOverlap;
        var spec = FanSpec(
          cardWidth: module.widthFor(scale),
          overlap: overlap,
          arc: module.handArc,
          tilt: module.handTilt,
          maxAlong: maxAlong,
          pivot: Alignment.bottomCenter,
        );
        var bounds = FanLayout.measure(count: cards.length, spec: spec);
        for (var i = 0; i < 10 && bounds.width > maxAlong; i++) {
          overlap = (overlap + 0.04).clamp(0.0, 0.84);
          spec = FanSpec(
            cardWidth: module.widthFor(scale),
            overlap: overlap,
            arc: module.handArc,
            tilt: module.handTilt,
            maxAlong: maxAlong,
            pivot: Alignment.bottomCenter,
          );
          bounds = FanLayout.measure(count: cards.length, spec: spec);
        }
        final slots = FanLayout.slots(count: cards.length, spec: spec);
        return SizedBox(
          width: bounds.width,
          height: bounds.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < cards.length; i++)
                _SouthCard(
                  slot: slots[i],
                  spec: spec,
                  bounds: bounds,
                  child: cards[i],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SouthCard extends StatelessWidget {
  const _SouthCard({
    required this.slot,
    required this.spec,
    required this.bounds,
    required this.child,
  });

  final FanSlot slot;
  final FanSpec spec;
  final FanBounds bounds;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final origin = FanLayout.frameOrigin(
      slot: slot,
      spec: spec,
      bounds: bounds,
    );
    return Positioned(
      left: origin.left,
      top: origin.top,
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
