import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/design/motion.dart';
import 'package:court_piece/design/table.dart';
import 'package:court_piece/design/theme.dart';
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

enum CardPresence { idle, playable, selected, dimmed, facedown }

final class CardView {
  const CardView({required this.id});

  final CardArtId id;
}

/// Face or back of a card. Size follows [CardScale] from [TableModule].
class PlayingCard extends StatelessWidget {
  PlayingCard({
    Key? key,
    required this.art,
    required this.view,
    required this.presence,
    this.scale = CardScale.trick,
    this.onTap,
  }) : super(key: key ?? ValueKey<CardArtId>(view.id));

  final CardArt art;
  final CardView view;
  final CardPresence presence;
  final CardScale scale;
  final VoidCallback? onTap;

  static const aspect = 5 / 7;

  @override
  Widget build(BuildContext context) {
    final module = TableScope.maybeOf(context);
    if (module != null) {
      final width = module.widthFor(scale);
      return _face(context, width, width / aspect);
    }
    return AspectRatio(
      aspectRatio: aspect,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _face(context, constraints.maxWidth, constraints.maxHeight);
        },
      ),
    );
  }

  Widget _face(BuildContext context, double width, double height) {
    final selected = presence == CardPresence.selected;
    final face = presence == CardPresence.facedown
        ? const _CardBack()
        : Image.asset(art.faceAsset(view.id), fit: BoxFit.contain);
    final liftTo = selected
        ? 1.0
        : presence == CardPresence.playable
        ? 0.45
        : 0.0;
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () {},
        child: SingleMotionBuilder(
          motion: CourtMotion.play(context),
          value: liftTo,
          builder: (context, lift, _) {
            return Transform.translate(
              offset: Offset(0, -36 * lift),
              child: Transform.scale(scale: 1 + (0.03 * lift), child: face),
            );
          },
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    return CustomPaint(
      painter: _BackPainter(theme.accent, theme.ink),
      child: const SizedBox.expand(),
    );
  }
}

class _BackPainter extends CustomPainter {
  const _BackPainter(this.accent, this.ink);

  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.shortestSide * 0.1;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(inset));
    canvas.drawRRect(rrect, Paint()..color = accent.withValues(alpha: 0.12));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.045,
    );
    final center = rect.center;
    final diamond = Path()
      ..moveTo(center.dx, rect.top + inset)
      ..lineTo(rect.right - inset, center.dy)
      ..lineTo(center.dx, rect.bottom - inset)
      ..lineTo(rect.left + inset, center.dy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()
        ..color = ink.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.035,
    );
  }

  @override
  bool shouldRepaint(_BackPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.ink != ink;
  }
}
