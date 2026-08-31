import 'package:flutter/painting.dart';

import '../foundation/metrics.dart';
import '../slots/card_visual.dart';

class LandingRecipe {
  const LandingRecipe({required this.widthFactor});

  final double widthFactor;

  factory LandingRecipe.of(Breakpoint breakpoint) {
    return switch (breakpoint) {
      Breakpoint.compact => const LandingRecipe(widthFactor: 1),
      Breakpoint.medium => const LandingRecipe(widthFactor: 0.62),
      Breakpoint.expanded => const LandingRecipe(widthFactor: 0.42),
    };
  }
}

class OverlayRecipe {
  const OverlayRecipe({required this.widthFactor});

  final double widthFactor;

  factory OverlayRecipe.of(Breakpoint breakpoint) {
    return switch (breakpoint) {
      Breakpoint.compact => const OverlayRecipe(widthFactor: 0.88),
      Breakpoint.medium => const OverlayRecipe(widthFactor: 0.5),
      Breakpoint.expanded => const OverlayRecipe(widthFactor: 0.36),
    };
  }
}

class TableRecipe {
  const TableRecipe({
    required this.southHeight,
    required this.southWidth,
    required this.northHeight,
    required this.northWidth,
    required this.sideWidth,
    required this.sideHeight,
    required this.trickWidth,
    required this.trickHeight,
  });

  final double southHeight;
  final double southWidth;
  final double northHeight;
  final double northWidth;
  final double sideWidth;
  final double sideHeight;
  final double trickWidth;
  final double trickHeight;

  factory TableRecipe.of(Breakpoint breakpoint) {
    return switch (breakpoint) {
      Breakpoint.compact => const TableRecipe(
        southHeight: 0.28,
        southWidth: 0.96,
        northHeight: 0.16,
        northWidth: 0.5,
        sideWidth: 0.18,
        sideHeight: 0.4,
        trickWidth: 0.42,
        trickHeight: 0.36,
      ),
      Breakpoint.medium => const TableRecipe(
        southHeight: 0.26,
        southWidth: 0.96,
        northHeight: 0.18,
        northWidth: 0.5,
        sideWidth: 0.18,
        sideHeight: 0.4,
        trickWidth: 0.42,
        trickHeight: 0.36,
      ),
      Breakpoint.expanded => const TableRecipe(
        southHeight: 0.24,
        southWidth: 0.96,
        northHeight: 0.2,
        northWidth: 0.5,
        sideWidth: 0.18,
        sideHeight: 0.4,
        trickWidth: 0.42,
        trickHeight: 0.36,
      ),
    };
  }
}

class FanRecipe {
  const FanRecipe({required this.spread, required this.tilt});

  final double spread;
  final double tilt;

  factory FanRecipe.of(Breakpoint breakpoint) {
    return switch (breakpoint) {
      Breakpoint.compact => const FanRecipe(spread: 0.55, tilt: 0.7),
      Breakpoint.medium => const FanRecipe(spread: 0.5, tilt: 0.58),
      Breakpoint.expanded => const FanRecipe(spread: 0.46, tilt: 0.48),
    };
  }
}

class TrickRecipe {
  const TrickRecipe();

  Alignment align(SeatVisual seat) {
    return switch (seat) {
      SeatVisual.south => const Alignment(0, 0.55),
      SeatVisual.north => const Alignment(0, -0.55),
      SeatVisual.west => const Alignment(-0.55, 0),
      SeatVisual.east => const Alignment(0.55, 0),
    };
  }
}
