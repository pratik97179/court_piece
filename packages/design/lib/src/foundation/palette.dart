import 'dart:ui';

class Palette {
  const Palette({
    required this.felt,
    required this.feltEdge,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.danger,
    required this.cardBack,
    required this.scrim,
  });

  final Color felt;
  final Color feltEdge;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color danger;
  final Color cardBack;
  final Color scrim;

  static const light = Palette(
    felt: Color(0xFFE7D9C4),
    feltEdge: Color(0xFFD0BFA6),
    surface: Color(0xFFF7F1E8),
    ink: Color(0xFF1C1917),
    muted: Color(0xFF6B635A),
    accent: Color(0xFF1E4A3A),
    onAccent: Color(0xFFF7F1E8),
    danger: Color(0xFF8F2D2D),
    cardBack: Color(0xFF1E4A3A),
    scrim: Color(0xCC1C1917),
  );

  static const dark = Palette(
    felt: Color(0xFF15261E),
    feltEdge: Color(0xFF0F1A15),
    surface: Color(0xFF1E3328),
    ink: Color(0xFFF3EDE4),
    muted: Color(0xFFB5A99A),
    accent: Color(0xFFC9A86A),
    onAccent: Color(0xFF15261E),
    danger: Color(0xFFE07070),
    cardBack: Color(0xFFC9A86A),
    scrim: Color(0xCC050807),
  );
}
