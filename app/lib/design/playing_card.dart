import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/design/recipe.dart';
import 'package:court_piece/design/table.dart';
import 'package:court_piece/design/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CardPresence { idle, playable, selected, dimmed, facedown }

final class CardView {
  const CardView({required this.id});

  final CardArtId id;
}

/// Face or back of a card. Size comes from [CourtRecipe].
class PlayingCard extends StatelessWidget {
  PlayingCard({
    Key? key,
    required this.art,
    required this.view,
    required this.presence,
    this.onTap,
  }) : super(key: key ?? ValueKey<CardArtId>(view.id));

  final CardArt art;
  final CardView view;
  final CardPresence presence;
  final VoidCallback? onTap;

  static const _aspect = 5 / 7;

  @override
  Widget build(BuildContext context) {
    final recipe = CourtScope.of(context).recipe;
    final table = TableScope.maybeOf(context);
    final theme = CourtTheme.of(context);
    final width = table?.cardWidth ?? recipe.cardWidth;
    final height = width / _aspect;
    final radius = BorderRadius.circular(
      table?.cardRadius ?? recipe.cardRadius,
    );
    final dimmed = presence == CardPresence.dimmed;
    final child = presence == CardPresence.facedown
        ? _CardBack(radius: radius)
        : SvgPicture.asset(
            art.faceAsset(view.id),
            fit: BoxFit.cover,
            width: width,
            height: height,
          );

    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: theme.surface,
          elevation: presence == CardPresence.selected ? 2 : 0,
          shadowColor: theme.ink,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: _border(theme)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: dimmed
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      theme.felt.withValues(alpha: 0.45),
                      BlendMode.srcATop,
                    ),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );
  }

  Color _border(CourtTheme theme) {
    return switch (presence) {
      CardPresence.selected => theme.accent,
      CardPresence.playable => theme.ink,
      CardPresence.idle => theme.muted,
      CardPresence.dimmed => theme.muted,
      CardPresence.facedown => theme.accent,
    };
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.radius});

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.felt, borderRadius: radius),
      child: CustomPaint(
        painter: _BackPainter(theme.accent, theme.ink),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BackPainter extends CustomPainter {
  const _BackPainter(this.accent, this.ink);

  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.shortestSide * 0.12;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.04;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(inset)),
      paint,
    );
    canvas.drawCircle(
      rect.center,
      size.shortestSide * 0.12,
      Paint()..color = ink.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_BackPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.ink != ink;
  }
}
