import 'dart:math' as math;

import 'package:court_piece/design/card_fan.dart';
import 'package:court_piece/design/motion.dart';
import 'package:court_piece/design/recipe.dart';
import 'package:court_piece/design/theme.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter/material.dart';

enum CardScale { opponent, trick, hand }

/// Card sizes for one table. Seats sit around the plate, not the screen.
@immutable
final class TableModule {
  const TableModule({
    required this.handWidth,
    required this.trickWidth,
    required this.opponentWidth,
    required this.handOverlap,
    required this.opponentOverlap,
    required this.handArc,
    required this.handTilt,
    required this.avatarSize,
    required this.inset,
    required this.gap,
    required this.plate,
    required this.plateMax,
    required this.opponentFanAlong,
    required this.handFanAlong,
  });

  final double handWidth;
  final double trickWidth;
  final double opponentWidth;
  final double handOverlap;
  final double opponentOverlap;
  final double handArc;
  final double handTilt;
  final double avatarSize;
  final double inset;
  final double gap;
  final double plate;
  final double plateMax;
  final double opponentFanAlong;
  final double handFanAlong;

  static const aspect = 5 / 7;

  static const handCount = 13;

  double get handHeight => handWidth / aspect;

  double get opponentHeight => opponentWidth / aspect;

  double get trickHeight => trickWidth / aspect;

  double get southHeight {
    final spec = FanSpec(
      cardWidth: handWidth,
      overlap: handOverlap,
      arc: handArc,
      tilt: handTilt,
      maxAlong: handFanAlong,
    );
    return FanLayout.measure(count: handCount, spec: spec).height + 10;
  }

  double get northSeatHeight {
    final fan = FanLayout.measure(count: handCount, spec: _opponentFanSpec());
    return avatarSize + 12 + fan.height;
  }

  double get sideSeatWidth {
    final fan = FanLayout.measure(
      count: handCount,
      spec: _opponentFanSpec(rotation: -math.pi / 2),
    );
    return avatarSize + 12 + fan.width;
  }

  double get sideSeatHeight {
    final fan = FanLayout.measure(
      count: handCount,
      spec: _opponentFanSpec(rotation: -math.pi / 2),
    );
    return math.max(avatarSize + 24, fan.height + 4);
  }

  FanSpec _opponentFanSpec({double rotation = 0}) {
    return FanSpec(
      cardWidth: opponentWidth,
      overlap: opponentOverlap,
      arc: 0.16,
      tilt: 0.14,
      rotation: rotation,
      maxAlong: opponentFanAlong,
    );
  }

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
    final handOverlap = switch (breakpoint) {
      CourtBreakpoint.compact => 0.6,
      CourtBreakpoint.medium => 0.5,
      CourtBreakpoint.expanded => 0.44,
    };
    final handFanAlong = switch (breakpoint) {
      CourtBreakpoint.compact => width * 0.94,
      CourtBreakpoint.medium => math.min(width * 0.68, 620.0),
      CourtBreakpoint.expanded => math.min(width * 0.74, 860.0),
    };
    final span = 1 + (handCount - 1) * (1 - handOverlap);
    var handWidth = handFanAlong / span;
    final handHCap =
        height *
        switch (breakpoint) {
          CourtBreakpoint.compact => 0.22,
          CourtBreakpoint.medium => 0.2,
          CourtBreakpoint.expanded => 0.2,
        };
    if (handWidth / aspect > handHCap) {
      handWidth = handHCap * aspect;
    }
    final trickWidth =
        handWidth *
        switch (breakpoint) {
          CourtBreakpoint.compact => 0.72,
          CourtBreakpoint.medium => 0.78,
          CourtBreakpoint.expanded => 0.8,
        };
    final opponentFanAlong = switch (breakpoint) {
      CourtBreakpoint.compact => math.min(width * 0.36, 118.0),
      CourtBreakpoint.medium => 132.0,
      CourtBreakpoint.expanded => 148.0,
    };
    return TableModule(
      handWidth: handWidth,
      trickWidth: trickWidth,
      opponentWidth: switch (breakpoint) {
        CourtBreakpoint.compact => 26.0,
        CourtBreakpoint.medium => 28.0,
        CourtBreakpoint.expanded => 30.0,
      },
      handOverlap: handOverlap,
      opponentOverlap: switch (breakpoint) {
        CourtBreakpoint.compact => 0.8,
        CourtBreakpoint.medium => 0.78,
        CourtBreakpoint.expanded => 0.76,
      },
      handArc: switch (breakpoint) {
        CourtBreakpoint.compact => 0.32,
        CourtBreakpoint.medium => 0.14,
        CourtBreakpoint.expanded => 0.11,
      },
      handTilt: switch (breakpoint) {
        CourtBreakpoint.compact => 0.15,
        CourtBreakpoint.medium => 0.09,
        CourtBreakpoint.expanded => 0.07,
      },
      avatarSize: switch (breakpoint) {
        CourtBreakpoint.compact => 22.0,
        CourtBreakpoint.medium => 24.0,
        CourtBreakpoint.expanded => 26.0,
      },
      inset: switch (breakpoint) {
        CourtBreakpoint.compact => 8.0,
        CourtBreakpoint.medium => 16.0,
        CourtBreakpoint.expanded => 24.0,
      },
      gap: switch (breakpoint) {
        CourtBreakpoint.compact => 6.0,
        CourtBreakpoint.medium => 10.0,
        CourtBreakpoint.expanded => 14.0,
      },
      plate: math.max(trickWidth * 2.55, (trickWidth / aspect) * 2.2),
      plateMax: switch (breakpoint) {
        CourtBreakpoint.compact => double.infinity,
        CourtBreakpoint.medium => 340.0,
        CourtBreakpoint.expanded => 380.0,
      },
      opponentFanAlong: opponentFanAlong,
      handFanAlong: handFanAlong,
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
        handArc == other.handArc &&
        handTilt == other.handTilt &&
        avatarSize == other.avatarSize &&
        inset == other.inset &&
        gap == other.gap &&
        plate == other.plate &&
        plateMax == other.plateMax &&
        opponentFanAlong == other.opponentFanAlong &&
        handFanAlong == other.handFanAlong;
  }

  @override
  int get hashCode {
    return Object.hash(
      handWidth,
      trickWidth,
      opponentWidth,
      handOverlap,
      opponentOverlap,
      handArc,
      handTilt,
      avatarSize,
      inset,
      gap,
      plate,
      plateMax,
      opponentFanAlong,
      handFanAlong,
    );
  }
}

/// Seat boxes around a centered plate.
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
    required this.southTop,
    required this.southHeight,
    required this.inset,
    required this.northHeight,
    required this.boardLeft,
    required this.boardTop,
    required this.boardWidth,
    required this.boardHeight,
  });

  final double northTop;
  final double westLeft;
  final double westTop;
  final double eastLeft;
  final double eastTop;
  final double plateLeft;
  final double plateTop;
  final double plate;
  final double southTop;
  final double southHeight;
  final double inset;
  final double northHeight;
  final double boardLeft;
  final double boardTop;
  final double boardWidth;
  final double boardHeight;

  factory TableLayout.from(Size size, TableModule module) {
    final inset = module.inset;
    final boardLeft = inset;
    final boardTop = inset;
    final boardWidth = math.max(1.0, size.width - 2 * inset);
    final boardHeight = math.max(1.0, size.height - 2 * inset);

    final northH = module.northSeatHeight;
    final sideW = module.sideSeatWidth;
    final sideH = module.sideSeatHeight;
    final southH = module.southHeight;
    var gap = module.gap;

    var leftoverW = boardWidth - 2 * sideW - 2 * gap;
    var leftoverH = boardHeight - northH - southH - 2 * gap;
    if (leftoverW < 48 || leftoverH < 48) {
      final scale = math.min(
        leftoverW < 48 ? (boardWidth - 2 * sideW) / (2 * gap + 48) : 1.0,
        leftoverH < 48 ? (boardHeight - northH - southH) / (2 * gap + 48) : 1.0,
      );
      gap *= scale.clamp(0.35, 1.0);
      leftoverW = boardWidth - 2 * sideW - 2 * gap;
      leftoverH = boardHeight - northH - southH - 2 * gap;
    }

    final leftover = math.min(leftoverW, leftoverH);
    var plate = leftover;
    if (plate > module.plateMax) {
      plate = module.plateMax;
    }
    if (plate < module.plate && leftover >= module.plate) {
      plate = math.min(module.plate, leftover);
    }
    plate = plate.clamp(48.0, math.max(48.0, leftover));

    final clusterW = sideW + gap + plate + gap + sideW;
    final clusterH = northH + gap + plate + gap + southH;
    final clusterLeft = boardLeft + (boardWidth - clusterW) / 2;
    final clusterTop = boardTop + (boardHeight - clusterH) / 2;
    final plateLeft = clusterLeft + sideW + gap;
    final plateTop = clusterTop + northH + gap;

    return TableLayout(
      northTop: clusterTop,
      westLeft: clusterLeft,
      westTop: plateTop + (plate - sideH) / 2,
      eastLeft: plateLeft + plate + gap,
      eastTop: plateTop + (plate - sideH) / 2,
      plateLeft: plateLeft,
      plateTop: plateTop,
      plate: plate,
      southTop: plateTop + plate + gap,
      southHeight: southH,
      inset: inset,
      northHeight: northH,
      boardLeft: boardLeft,
      boardTop: boardTop,
      boardWidth: boardWidth,
      boardHeight: boardHeight,
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

/// Played cards fly in from each seat, then collect toward the trick winner.
class TrickWell extends StatelessWidget {
  const TrickWell({
    super.key,
    this.north,
    this.east,
    this.south,
    this.west,
    this.collectWinner,
    this.onCollected,
    this.onCardLanded,
  });

  final Widget? north;
  final Widget? east;
  final Widget? south;
  final Widget? west;
  final Seat? collectWinner;
  final VoidCallback? onCollected;
  final VoidCallback? onCardLanded;

  static Alignment _seatFrom(Seat seat) {
    return switch (seat) {
      Seat.north => const Alignment(0, -1.35),
      Seat.south => const Alignment(0, 1.35),
      Seat.west => const Alignment(-1.35, 0),
      Seat.east => const Alignment(1.35, 0),
    };
  }

  static Alignment _seatSlot(Seat seat) {
    return switch (seat) {
      Seat.north => const Alignment(0, -0.38),
      Seat.south => const Alignment(0, 0.38),
      Seat.west => const Alignment(-0.38, 0),
      Seat.east => const Alignment(0.38, 0),
    };
  }

  static Alignment _winnerToward(Seat seat) {
    return switch (seat) {
      Seat.north => const Alignment(0, -0.95),
      Seat.south => const Alignment(0, 0.95),
      Seat.west => const Alignment(-0.95, 0),
      Seat.east => const Alignment(0.95, 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final collecting = collectWinner != null;
    final slots = <Seat, Widget?>{
      Seat.north: north,
      Seat.east: east,
      Seat.south: south,
      Seat.west: west,
    };
    var pending = 0;
    for (final entry in slots.entries) {
      if (entry.value != null) {
        pending += 1;
      }
    }
    void slotDone() {
      pending -= 1;
      if (pending <= 0) {
        onCollected?.call();
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        for (final entry in slots.entries)
          if (entry.value != null)
            _TrickSlot(
              key: ValueKey<String>('trick-${entry.key.name}'),
              seat: entry.key,
              from: _seatFrom(entry.key),
              to: _seatSlot(entry.key),
              toward: collecting ? _winnerToward(collectWinner!) : null,
              onCollected: collecting ? slotDone : null,
              onCardLanded: collecting ? null : onCardLanded,
              child: entry.value,
            ),
      ],
    );
  }
}

class _TrickSlot extends StatefulWidget {
  const _TrickSlot({
    super.key,
    required this.seat,
    required this.from,
    required this.to,
    required this.child,
    this.toward,
    this.onCollected,
    this.onCardLanded,
  });

  final Seat seat;
  final Alignment from;
  final Alignment to;
  final Alignment? toward;
  final Widget? child;
  final VoidCallback? onCollected;
  final VoidCallback? onCardLanded;

  @override
  State<_TrickSlot> createState() => _TrickSlotState();
}

class _TrickSlotState extends State<_TrickSlot> {
  Widget? _held;
  var _entered = false;
  var _collecting = false;
  var _pendingCollect = false;

  @override
  void initState() {
    super.initState();
    _held = widget.child;
    _entered = widget.child == null;
  }

  @override
  void didUpdateWidget(_TrickSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newKey = widget.child?.key;
    final oldKey = oldWidget.child?.key;
    if (newKey != oldKey) {
      if (widget.child != null) {
        _held = widget.child;
        _entered = false;
        _collecting = false;
      } else if (widget.toward == null) {
        _held = null;
        _entered = false;
        _pendingCollect = false;
        _collecting = false;
      }
    }
    if (widget.toward != null && _held != null) {
      _pendingCollect = true;
      if (_entered) {
        _collecting = true;
      }
    }
    if (widget.toward == null) {
      _pendingCollect = false;
      _collecting = false;
    }
  }

  void _onEntered() {
    if (!mounted) {
      return;
    }
    setState(() {
      _entered = true;
      if (_pendingCollect) {
        _collecting = true;
      }
    });
    widget.onCardLanded?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_held == null) {
      return const SizedBox.shrink();
    }
    if (_collecting && widget.toward != null) {
      return CourtCollect(
        from: widget.to,
        toward: widget.toward!,
        onFinished: widget.onCollected,
        child: _held!,
      );
    }
    if (!_entered) {
      return CourtFlight(
        key: ValueKey<Object?>(_held!.key),
        from: widget.from,
        to: widget.to,
        visible: true,
        onFinished: () {
          if (mounted) {
            _onEntered();
          }
        },
        child: _held!,
      );
    }
    return Align(alignment: widget.to, child: _held!);
  }
}

/// Four seats around one table. Positions come from the plate center.
class GameTable extends StatelessWidget {
  const GameTable({
    super.key,
    required this.north,
    required this.east,
    required this.south,
    required this.west,
    required this.well,
    this.score,
    this.trump,
  });

  final Widget north;
  final Widget east;
  final Widget south;
  final Widget west;
  final Widget well;
  final Widget? score;
  final Widget? trump;

  @override
  Widget build(BuildContext context) {
    final breakpoint = CourtScope.of(context).breakpoint;
    final theme = CourtTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final module = TableModule.from(constraints, breakpoint);
        final layout = TableLayout.from(constraints.biggest, module);
        final boardFill = Color.lerp(
          theme.felt,
          theme.surface,
          theme.brightness == Brightness.dark ? 0.1 : 0.18,
        )!;
        final plateFill = Color.lerp(boardFill, theme.felt, 0.32)!;
        final radius = math.min(layout.boardWidth, layout.boardHeight) * 0.045;
        return TableScope(
          module: module,
          child: ColoredBox(
            color: theme.felt,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: layout.boardLeft,
                  top: layout.boardTop,
                  width: layout.boardWidth,
                  height: layout.boardHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: boardFill,
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: theme.ink.withValues(alpha: 0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: layout.plateLeft,
                  top: layout.northTop,
                  width: layout.plate,
                  height: layout.northHeight,
                  child: Align(alignment: Alignment.bottomCenter, child: north),
                ),
                Positioned(
                  left: layout.westLeft,
                  top: layout.westTop,
                  width: module.sideSeatWidth,
                  height: module.sideSeatHeight,
                  child: Align(alignment: Alignment.centerRight, child: west),
                ),
                Positioned(
                  left: layout.eastLeft,
                  top: layout.eastTop,
                  width: module.sideSeatWidth,
                  height: module.sideSeatHeight,
                  child: Align(alignment: Alignment.centerLeft, child: east),
                ),
                Positioned(
                  left: layout.plateLeft,
                  top: layout.plateTop,
                  width: layout.plate,
                  height: layout.plate,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: plateFill,
                      borderRadius: BorderRadius.circular(layout.plate * 0.2),
                    ),
                    child: well,
                  ),
                ),
                Positioned(
                  left: layout.boardLeft,
                  width: layout.boardWidth,
                  top: layout.southTop,
                  height: layout.southHeight,
                  child: Align(alignment: Alignment.bottomCenter, child: south),
                ),
                if (score != null)
                  Positioned(
                    left: layout.boardLeft,
                    top: layout.boardTop + module.inset * 0.35,
                    width: layout.boardWidth,
                    child: Center(child: score!),
                  ),
                if (trump != null)
                  Positioned(
                    left: layout.plateLeft + layout.plate * 0.72,
                    top: layout.plateTop + layout.plate * 0.06,
                    child: trump!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
