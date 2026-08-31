import 'package:flutter/material.dart';

enum CourtBreakpoint { compact, medium, expanded }

/// Layout metrics for a [CourtBreakpoint]. Numbers stay in this file.
@immutable
final class CourtRecipe {
  const CourtRecipe._({
    required this.inset,
    required this.gap,
    required this.titleSize,
    required this.cardWidth,
    required this.cardRadius,
  });

  final double inset;
  final double gap;
  final double titleSize;
  final double cardWidth;
  final double cardRadius;

  static CourtRecipe forBreakpoint(CourtBreakpoint breakpoint) {
    return switch (breakpoint) {
      CourtBreakpoint.compact => const CourtRecipe._(
        inset: 12,
        gap: 8,
        titleSize: 18,
        cardWidth: 56,
        cardRadius: 4,
      ),
      CourtBreakpoint.medium => const CourtRecipe._(
        inset: 16,
        gap: 8,
        titleSize: 22,
        cardWidth: 72,
        cardRadius: 6,
      ),
      CourtBreakpoint.expanded => const CourtRecipe._(
        inset: 24,
        gap: 12,
        titleSize: 24,
        cardWidth: 88,
        cardRadius: 8,
      ),
    };
  }

  static CourtBreakpoint resolve(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    if (width < 600) {
      return CourtBreakpoint.compact;
    }
    if (width < 840) {
      return CourtBreakpoint.medium;
    }
    return CourtBreakpoint.expanded;
  }
}

/// Provides [CourtBreakpoint] and [CourtRecipe] under [CourtScreen].
class CourtScope extends InheritedWidget {
  const CourtScope({
    super.key,
    required this.breakpoint,
    required this.recipe,
    required super.child,
  });

  final CourtBreakpoint breakpoint;
  final CourtRecipe recipe;

  static CourtScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CourtScope>();
    assert(scope != null);
    return scope!;
  }

  @override
  bool updateShouldNotify(CourtScope oldWidget) {
    return breakpoint != oldWidget.breakpoint || recipe != oldWidget.recipe;
  }
}
