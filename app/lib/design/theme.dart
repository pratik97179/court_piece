import 'package:flutter/material.dart';

@immutable
final class _TokenPalette {
  const _TokenPalette({
    required this.felt,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.surface,
    required this.danger,
  });

  final Color felt;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color surface;
  final Color danger;

  static const light = _TokenPalette(
    felt: Color(0xFFF3F0E8),
    ink: Color(0xFF1B1A17),
    muted: Color(0xFF6E6A62),
    accent: Color(0xFF9A3B2F),
    surface: Color(0xFFFFFCF6),
    danger: Color(0xFFB42318),
  );

  static const dark = _TokenPalette(
    felt: Color(0xFF161714),
    ink: Color(0xFFE7E2D8),
    muted: Color(0xFF9B968C),
    accent: Color(0xFFD2A56A),
    surface: Color(0xFF22241F),
    danger: Color(0xFFE26D5A),
  );
}

abstract final class _TokenType {
  static const double title = 22;
  static const double body = 16;
  static const double caption = 13;
}

abstract final class _TokenSpace {
  static const double sm = 8;
}

abstract final class _TokenMotion {
  static const Duration play = Duration(milliseconds: 280);
}

/// Semantic colors and Material [ThemeData] for light and dark felt.
@immutable
final class CourtTheme extends ThemeExtension<CourtTheme> {
  const CourtTheme({
    required this.brightness,
    required this.felt,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.surface,
    required this.danger,
  });

  factory CourtTheme.light() =>
      CourtTheme._from(Brightness.light, _TokenPalette.light);

  factory CourtTheme.dark() =>
      CourtTheme._from(Brightness.dark, _TokenPalette.dark);

  factory CourtTheme._from(Brightness brightness, _TokenPalette palette) {
    return CourtTheme(
      brightness: brightness,
      felt: palette.felt,
      ink: palette.ink,
      muted: palette.muted,
      accent: palette.accent,
      surface: palette.surface,
      danger: palette.danger,
    );
  }

  final Brightness brightness;
  final Color felt;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color surface;
  final Color danger;

  static CourtTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<CourtTheme>();
    assert(theme != null, 'CourtTheme is missing from ThemeData.extensions');
    return theme!;
  }

  ThemeData asMaterial() {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: felt,
      secondary: muted,
      onSecondary: felt,
      error: danger,
      onError: felt,
      surface: felt,
      onSurface: ink,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: felt,
      canvasColor: felt,
      iconTheme: IconThemeData(color: ink),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(_TokenSpace.sm)),
          animationDuration: _TokenMotion.play,
        ),
      ),
      textTheme: TextTheme(
        titleMedium: TextStyle(
          color: ink,
          fontSize: _TokenType.title,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        bodyMedium: TextStyle(
          color: ink,
          fontSize: _TokenType.body,
          fontWeight: FontWeight.w300,
          height: 1.4,
          letterSpacing: 0.2,
        ),
        bodySmall: TextStyle(
          color: muted,
          fontSize: _TokenType.caption,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.2,
        ),
      ),
      extensions: [this],
    );
  }

  @override
  CourtTheme copyWith({
    Brightness? brightness,
    Color? felt,
    Color? ink,
    Color? muted,
    Color? accent,
    Color? surface,
    Color? danger,
  }) {
    return CourtTheme(
      brightness: brightness ?? this.brightness,
      felt: felt ?? this.felt,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      surface: surface ?? this.surface,
      danger: danger ?? this.danger,
    );
  }

  @override
  CourtTheme lerp(ThemeExtension<CourtTheme>? other, double t) {
    if (other is! CourtTheme) {
      return this;
    }
    return CourtTheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      felt: Color.lerp(felt, other.felt, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
