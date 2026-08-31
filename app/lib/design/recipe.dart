import 'package:flutter/material.dart';

enum CourtBreakpoint { compact, medium, expanded }

/// Type scale for a [CourtBreakpoint].
@immutable
final class CourtRecipe {
  const CourtRecipe._({required this.titleSize});

  final double titleSize;

  static CourtRecipe forBreakpoint(CourtBreakpoint breakpoint) {
    return switch (breakpoint) {
      CourtBreakpoint.compact => const CourtRecipe._(titleSize: 18),
      CourtBreakpoint.medium => const CourtRecipe._(titleSize: 22),
      CourtBreakpoint.expanded => const CourtRecipe._(titleSize: 24),
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
