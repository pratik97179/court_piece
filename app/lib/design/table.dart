import 'dart:math' as math;

import 'package:court_piece/design/recipe.dart';
import 'package:court_piece/design/theme.dart';
import 'package:flutter/material.dart';

enum CardScale { opponent, trick, hand }

/// Card sizes for one table. Positions come from [TableLayout].
@immutable
final class TableModule {
  const TableModule({
    required this.handWidth,
    required this.trickWidth,
    required this.opponentWidth,
    required this.handOverlap,
    required this.opponentOverlap,
    required this.inset,
    required this.gap,
    required this.plate,
  });

  final double handWidth;
  final double trickWidth;
  final double opponentWidth;
  final double handOverlap;
  final double opponentOverlap;
  final double inset;
  final double gap;
  final double plate;

  static const aspect = 5 / 7;

  double get handHeight => handWidth / aspect;

  double get opponentHeight => opponentWidth / aspect;

  double get trickHeight => trickWidth / aspect;

  double widthFor(CardScale scale) {
    return switch (scale) {
      CardScale.hand => handWidth,
      CardScale.trick => trickWidth,
      CardScale.opponent => opponentWidth,
    };
  }

  double overlapFor(CardScale scale) {
    return switch (scale) {
      CardScale.hand => handOverlap,
      CardScale.opponent => opponentOverlap,
      CardScale.trick => 0,
    };
  }

  factory TableModule.from(
    BoxConstraints constraints,
    CourtBreakpoint breakpoint,
  ) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final short = math.min(width, height);
    final handCap = switch (breakpoint) {
      CourtBreakpoint.compact => short * 0.26,
      CourtBreakpoint.medium => 152.0,
      CourtBreakpoint.expanded => 172.0,
    };
    final handHeight = math.min(height * 0.2, handCap);
    final handWidth = handHeight * aspect;
    final trickWidth =
        handWidth *
        switch (breakpoint) {
          CourtBreakpoint.compact => 0.76,
          CourtBreakpoint.medium => 0.82,
          CourtBreakpoint.expanded => 0.86,
        };
    return TableModule(
      handWidth: handWidth,
      trickWidth: trickWidth,
      opponentWidth:
          handWidth *
          switch (breakpoint) {
            CourtBreakpoint.compact => 0.55,
            CourtBreakpoint.medium => 0.6,
            CourtBreakpoint.expanded => 0.63,
          },
      handOverlap: switch (breakpoint) {
        CourtBreakpoint.compact => 0.5,
        CourtBreakpoint.medium => 0.36,
        CourtBreakpoint.expanded => 0.22,
      },
      opponentOverlap: switch (breakpoint) {
        CourtBreakpoint.compact => 0.56,
        CourtBreakpoint.medium => 0.48,
        CourtBreakpoint.expanded => 0.4,
      },
      inset:
          short *
          switch (breakpoint) {
            CourtBreakpoint.compact => 0.02,
            CourtBreakpoint.medium => 0.026,
            CourtBreakpoint.expanded => 0.03,
          },
      gap: (short * 0.03).clamp(10.0, 22.0),
      plate: (trickWidth / aspect) * 1.85,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TableModule &&
        handWidth == other.handWidth &&
        trickWidth == other.trickWidth &&
        opponentWidth == other.opponentWidth &&
        handOverlap == other.handOverlap &&
        opponentOverlap == other.opponentOverlap &&
        inset == other.inset &&
        gap == other.gap &&
        plate == other.plate;
  }

  @override
  int get hashCode {
    return Object.hash(
      handWidth,
      trickWidth,
      opponentWidth,
      handOverlap,
      opponentOverlap,
      inset,
      gap,
      plate,
    );
  }
}

/// Pixel placement of seats around the trick. Slack sits outside the cluster.
@immutable
final class TableLayout {
  const TableLayout({
    required this.northTop,
    required this.westLeft,
    required this.westTop,
    required this.eastLeft,
    required this.eastTop,
    required this.plateLeft,
    required this.plateTop,
    required this.plate,
    required this.southHeight,
    required this.bottomPad,
    required this.inset,
    required this.northHeight,
  });

  final double northTop;
  final double westLeft;
  final double westTop;
  final double eastLeft;
  final double eastTop;
  final double plateLeft;
  final double plateTop;
  final double plate;
  final double southHeight;
  final double bottomPad;
  final double inset;
  final double northHeight;

  factory TableLayout.from(Size size, TableModule module) {
    final inset = module.inset;
    final oppW = module.opponentWidth;
    final oppH = module.opponentHeight;
    final southH = module.handHeight * 1.1;
    final westH = oppH + 4 * oppH * (1 - module.opponentOverlap);
    var plate = module.plate;
    var gap = module.gap;
    final bottomPad = inset * 1.5;
    final topPad = inset;
    final sidePad = inset;

    final maxPlateW = size.width - 2 * sidePad - 2 * oppW - 2 * gap;
    if (plate > maxPlateW) {
      plate = math.max(module.trickHeight * 1.35, maxPlateW);
    }

    final southTop = size.height - bottomPad - southH;
    final playH = southTop - topPad;
    var clusterH = oppH + gap + plate + gap;
    if (clusterH > playH && clusterH > 0) {
      final scale = playH / clusterH;
      plate *= scale;
      gap *= scale;
      clusterH = oppH + gap + plate + gap;
    }

    final slack = math.max(0.0, playH - clusterH);
    final northTop = topPad + slack * 0.58;
    final plateTop = northTop + oppH + gap;
    final plateLeft = (size.width - plate) / 2;
    final plateCenterY = plateTop + plate / 2;

    var westLeft = plateLeft - gap - oppW;
    if (westLeft < sidePad) {
      westLeft = sidePad;
    }
    var eastLeft = plateLeft + plate + gap;
    if (eastLeft + oppW > size.width - sidePad) {
      eastLeft = size.width - sidePad - oppW;
    }

    var westTop = plateCenterY - westH / 2;
    westTop = westTop.clamp(topPad, math.max(topPad, southTop - westH));

    return TableLayout(
      northTop: northTop,
      westLeft: westLeft,
      westTop: westTop,
      eastLeft: eastLeft,
      eastTop: westTop,
      plateLeft: plateLeft,
      plateTop: plateTop,
      plate: plate,
      southHeight: southH,
      bottomPad: bottomPad,
      inset: inset,
      northHeight: oppH,
    );
  }
}

class TableScope extends InheritedWidget {
  const TableScope({super.key, required this.module, required super.child});

  final TableModule module;

  static TableModule? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TableScope>()?.module;
  }

  @override
  bool updateShouldNotify(TableScope oldWidget) {
    return module != oldWidget.module;
  }
}

/// Played cards sit toward the seat that played them.
class TrickWell extends StatelessWidget {
  const TrickWell({super.key, this.north, this.east, this.south, this.west});

  final Widget? north;
  final Widget? east;
  final Widget? south;
  final Widget? west;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.ink.withValues(alpha: 0.028),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (north != null)
            Align(alignment: const Alignment(0, -0.3), child: north),
          if (south != null)
            Align(alignment: const Alignment(0, 0.3), child: south),
          if (west != null)
            Align(alignment: const Alignment(-0.3, 0), child: west),
          if (east != null)
            Align(alignment: const Alignment(0.3, 0), child: east),
        ],
      ),
    );
  }
}

/// Four seats and a center well on a felt surface.
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
    final breakpoint = CourtScope.of(context).breakpoint;
    return LayoutBuilder(
      builder: (context, constraints) {
        final module = TableModule.from(constraints, breakpoint);
        final layout = TableLayout.from(constraints.biggest, module);
        return TableScope(
          module: module,
          child: _TableFelt(
            child: Stack(
              children: [
                Positioned(
                  left: layout.inset,
                  right: layout.inset,
                  top: layout.northTop,
                  height: layout.northHeight,
                  child: Center(child: north),
                ),
                Positioned(
                  left: layout.westLeft,
                  top: layout.westTop,
                  child: west,
                ),
                Positioned(
                  left: layout.eastLeft,
                  top: layout.eastTop,
                  child: east,
                ),
                Positioned(
                  left: layout.plateLeft,
                  top: layout.plateTop,
                  width: layout.plate,
                  height: layout.plate,
                  child: well,
                ),
                Positioned(
                  left: layout.inset,
                  right: layout.inset,
                  bottom: layout.bottomPad,
                  height: layout.southHeight,
                  child: Center(child: south),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TableFelt extends StatelessWidget {
  const _TableFelt({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final wash = Color.lerp(theme.felt, theme.surface, dark ? 0.08 : 0.16)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(radius: 0.9, colors: [wash, theme.felt]),
      ),
      child: child,
    );
  }
}
