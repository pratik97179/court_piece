import 'package:flutter/material.dart';

import '../foundation/metrics.dart';
import '../foundation/palette.dart';

/// Resolved design grammar for the current size and brightness.
class DesignScope extends InheritedWidget {
  const DesignScope({
    super.key,
    required this.palette,
    required this.space,
    required this.type,
    required this.breakpoint,
    required super.child,
  });

  final Palette palette;
  final Space space;
  final TypeScale type;
  final Breakpoint breakpoint;

  static DesignScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DesignScope>();
    assert(scope != null, 'DesignScope missing');
    return scope!;
  }

  @override
  bool updateShouldNotify(DesignScope old) =>
      palette != old.palette ||
      space.unit != old.space.unit ||
      breakpoint != old.breakpoint;
}

ThemeData get lightTheme => buildTheme(Palette.light);

ThemeData get darkTheme => buildTheme(Palette.dark);

ThemeData buildTheme(Palette palette) {
  final base = palette == Palette.light ? ThemeData.light() : ThemeData.dark();
  return base.copyWith(
    colorScheme: ColorScheme(
      brightness: palette == Palette.light ? Brightness.light : Brightness.dark,
      primary: palette.accent,
      onPrimary: palette.onAccent,
      secondary: palette.accent,
      onSecondary: palette.onAccent,
      error: palette.danger,
      onError: palette.onAccent,
      surface: palette.surface,
      onSurface: palette.ink,
    ),
    scaffoldBackgroundColor: palette.felt,
    splashFactory: NoSplash.splashFactory,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    ),
  );
}
