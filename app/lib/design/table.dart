import 'dart:math' as math;

import 'package:flutter/material.dart';

@immutable
final class TableGeometry {
  const TableGeometry({
    required this.cardWidth,
    required this.cardRadius,
    required this.seatInset,
    required this.wellSize,
  });

  final double cardWidth;
  final double cardRadius;
  final double seatInset;
  final double wellSize;

  factory TableGeometry.from(BoxConstraints constraints) {
    final short = math.min(constraints.maxWidth, constraints.maxHeight);
    final cardWidth = (short * 0.11).clamp(52.0, 92.0);
    return TableGeometry(
      cardWidth: cardWidth,
      cardRadius: cardWidth * 0.08,
      seatInset: short * 0.03,
      wellSize: cardWidth * 2.2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TableGeometry &&
        cardWidth == other.cardWidth &&
        cardRadius == other.cardRadius &&
        seatInset == other.seatInset &&
        wellSize == other.wellSize;
  }

  @override
  int get hashCode {
    return Object.hash(cardWidth, cardRadius, seatInset, wellSize);
  }
}

class TableScope extends InheritedWidget {
  const TableScope({super.key, required this.geometry, required super.child});

  final TableGeometry geometry;

  static TableGeometry? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TableScope>()?.geometry;
  }

  @override
  bool updateShouldNotify(TableScope oldWidget) {
    return geometry != oldWidget.geometry;
  }
}

/// Four seats and a center well. The only way to lay out a table.
class GameTable extends StatelessWidget {
  const GameTable({
    super.key,
    required this.north,
    required this.east,
    required this.south,
    required this.west,
    required this.well,
  });

  final Widget north;
  final Widget east;
  final Widget south;
  final Widget west;
  final Widget well;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = TableGeometry.from(constraints);
        final inset = geometry.seatInset;
        return TableScope(
          geometry: geometry,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: inset),
                  child: north,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: inset),
                  child: RotatedBox(quarterTurns: 1, child: east),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: inset),
                  child: south,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: inset),
                  child: RotatedBox(quarterTurns: 3, child: west),
                ),
              ),
              Center(
                child: SizedBox(
                  width: geometry.wellSize,
                  height: geometry.wellSize,
                  child: well,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
