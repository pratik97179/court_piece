import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/motion.dart';
import '../foundation/palette.dart';
import '../slots/card_visual.dart';
import '../theme/app_theme.dart';

class PlayingCard extends StatelessWidget {
  const PlayingCard({
    super.key,
    required this.visual,
    this.onPlay,
  });

  final CardVisual visual;
  final ValueChanged<CardVisual>? onPlay;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AspectRatio(
      aspectRatio: 2.5 / 3.5,
      child: RepaintBoundary(
        child: AnimatedScale(
        scale: visual.playable ? 1.04 : 1,
        duration: Motion.of(context, Motion.fast),
        curve: Motion.curve,
        child: Opacity(
          opacity: visual.faceUp && !visual.playable && onPlay != null ? 0.45 : 1,
          child: GestureDetector(
            onTap: onPlay == null
                ? null
                : () => onPlay!(visual),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: visual.faceUp ? design.palette.surface : design.palette.cardBack,
                borderRadius: BorderRadius.circular(design.space.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: design.palette.ink.withValues(alpha: 0.18),
                    blurRadius: design.space.sm,
                    offset: Offset(0, design.space.xs),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(design.space.cardRadius),
                child: visual.faceUp
                    ? SvgPicture.asset(
                        visual.assetPath,
                        package: 'court_piece_design',
                        fit: BoxFit.contain,
                      )
                    : _Back(palette: design.palette, reduced: reduced),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.palette, required this.reduced});

  final Palette palette;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    final space = DesignScope.of(context).space;
    return CustomPaint(
      painter: _BackPainter(palette: palette, inset: space.sm),
      child: reduced ? null : const SizedBox.expand(),
    );
  }
}

class _BackPainter extends CustomPainter {
  _BackPainter({required this.palette, required this.inset});

  final Palette palette;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      Radius.circular(inset),
    );
    final paint = Paint()
      ..color = palette.onAccent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = inset * 0.2;
    canvas.drawRRect(r, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), inset * 1.2, paint);
  }

  @override
  bool shouldRepaint(_BackPainter old) => old.palette != palette;
}
