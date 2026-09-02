import 'package:court_piece/design/recipe.dart';
import 'package:court_piece/design/theme.dart';
import 'package:court_piece/domain/card.dart';
import 'package:flutter/material.dart';

/// Tricks this deal and courts in the match.
class ScorePips extends StatelessWidget {
  const ScorePips({
    super.key,
    required this.northSouthTricks,
    required this.eastWestTricks,
    required this.northSouthCourts,
    required this.eastWestCourts,
    this.trickCap = 7,
    this.courtCap = 7,
  });

  final int northSouthTricks;
  final int eastWestTricks;
  final int northSouthCourts;
  final int eastWestCourts;
  final int trickCap;
  final int courtCap;

  @override
  Widget build(BuildContext context) {
    final recipe = CourtScope.of(context).recipe;
    return Row(
      key: const ValueKey<String>('score-pips'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _TeamPips(
          key: const ValueKey<String>('score-us'),
          label: 'Us',
          tricks: northSouthTricks,
          courts: northSouthCourts,
          trickCap: trickCap,
          courtCap: courtCap,
        ),
        SizedBox(width: recipe.titleSize * 0.9),
        _TeamPips(
          key: const ValueKey<String>('score-them'),
          label: 'Them',
          tricks: eastWestTricks,
          courts: eastWestCourts,
          trickCap: trickCap,
          courtCap: courtCap,
        ),
      ],
    );
  }
}

class _TeamPips extends StatelessWidget {
  const _TeamPips({
    super.key,
    required this.label,
    required this.tricks,
    required this.courts,
    required this.trickCap,
    required this.courtCap,
  });

  final String label;
  final int tricks;
  final int courts;
  final int trickCap;
  final int courtCap;

  @override
  Widget build(BuildContext context) {
    final recipe = CourtScope.of(context).recipe;
    final theme = CourtTheme.of(context);
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: theme.muted,
      fontSize: recipe.titleSize * 0.55,
      letterSpacing: 0.4,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        SizedBox(height: recipe.titleSize * 0.12),
        _PipRow(
          filled: tricks,
          total: trickCap,
          filledColor: theme.accent,
          emptyColor: theme.ink.withValues(alpha: 0.12),
        ),
        SizedBox(height: recipe.titleSize * 0.16),
        _PipRow(
          filled: courts,
          total: courtCap,
          filledColor: theme.ink.withValues(alpha: 0.72),
          emptyColor: theme.ink.withValues(alpha: 0.08),
          size: recipe.titleSize * 0.34,
        ),
      ],
    );
  }
}

class _PipRow extends StatelessWidget {
  const _PipRow({
    required this.filled,
    required this.total,
    required this.filledColor,
    required this.emptyColor,
    this.size,
  });

  final int filled;
  final int total;
  final Color filledColor;
  final Color emptyColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final recipe = CourtScope.of(context).recipe;
    final dot = size ?? recipe.titleSize * 0.42;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dot * 0.12),
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? filledColor : emptyColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// Current trump suit during play.
class TrumpMark extends StatelessWidget {
  const TrumpMark({super.key, required this.suit});

  final Suit suit;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    final recipe = CourtScope.of(context).recipe;
    final red = suit == Suit.hearts || suit == Suit.diamonds;
    return DecoratedBox(
      key: ValueKey<String>('trump-mark-${suit.name}'),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(recipe.titleSize * 0.28),
        border: Border.all(color: theme.ink.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: recipe.titleSize * 0.38,
          vertical: recipe.titleSize * 0.18,
        ),
        child: Text(
          _suitMark(suit),
          style: TextStyle(
            color: red ? theme.accent : theme.ink,
            fontSize: recipe.titleSize * 0.95,
            height: 1,
          ),
        ),
      ),
    );
  }
}

String _suitMark(Suit suit) {
  return switch (suit) {
    Suit.clubs => '\u2663',
    Suit.diamonds => '\u2666',
    Suit.hearts => '\u2665',
    Suit.spades => '\u2660',
  };
}
