import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/motion.dart';
import '../recipes/layout.dart';
import '../slots/card_visual.dart';
import '../slots/hud_meters.dart';
import '../slots/seat_slot.dart';
import '../slots/trick_cluster.dart';
import '../theme/app_theme.dart';
import 'host_shell.dart';
import 'playing_card.dart';

class TableHost extends StatelessWidget {
  const TableHost({
    super.key,
    required this.hud,
    required this.north,
    required this.east,
    required this.south,
    required this.west,
    required this.center,
    this.overlay,
    this.banner,
    this.onLeave,
  });

  final HudMeters hud;
  final SeatSlot north;
  final SeatSlot east;
  final SeatSlot south;
  final SeatSlot west;
  final TrickCluster center;
  final Widget? overlay;
  final String? banner;
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    return HostShell(
      builder: (context, design) {
        final table = TableRecipe.of(design.breakpoint);
        return Material(
          color: design.palette.felt,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: table.northHeight,
                    widthFactor: table.northWidth,
                    child: _SeatView(slot: north),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: table.sideWidth,
                    heightFactor: table.sideHeight,
                    child: _SeatView(slot: east),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: table.sideWidth,
                    heightFactor: table.sideHeight,
                    child: _SeatView(slot: west),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: table.trickWidth,
                    heightFactor: table.trickHeight,
                    child: _TrickView(cluster: center),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: table.southHeight,
                    widthFactor: table.southWidth,
                    child: _SeatView(slot: south),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: _Hud(hud: hud, onLeave: onLeave),
                ),
                if (banner != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: design.space.sm),
                      child: Text(
                        banner!,
                        style: design.type.label.copyWith(color: design.palette.danger),
                      ),
                    ),
                  ),
                if (overlay != null) Positioned.fill(child: overlay!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.hud, this.onLeave});

  final HudMeters hud;
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return Padding(
      padding: EdgeInsets.all(design.space.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onLeave != null)
            IconButton(
              onPressed: onLeave,
              icon: Icon(Icons.close, color: design.palette.ink),
            ),
          _Meter(label: 'Tricks', us: hud.tricksUs, them: hud.tricksThem),
          SizedBox(width: design.space.sm),
          _Meter(label: 'Courts', us: hud.courtsUs, them: hud.courtsThem),
          if (hud.trumpLabel.isNotEmpty) ...[
            SizedBox(width: design.space.sm),
            Text(
              hud.trumpLabel,
              style: design.type.label.copyWith(color: design.palette.accent),
            ),
          ],
        ],
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.label, required this.us, required this.them});

  final String label;
  final int us;
  final int them;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: us, end: us),
      duration: Motion.of(context, Motion.fast),
      builder: (context, _, _) {
        return Text(
          '$label  $us-$them',
          style: design.type.label.copyWith(color: design.palette.ink),
        );
      },
    );
  }
}

class _SeatView extends StatelessWidget {
  const _SeatView({required this.slot});

  final SeatSlot slot;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    final ring = slot.isTurn ? design.palette.accent : Colors.transparent;
    return AnimatedContainer(
      duration: Motion.of(context, Motion.fast),
      curve: Motion.curve,
      decoration: BoxDecoration(
        border: Border.all(color: ring, width: design.space.hair),
        borderRadius: BorderRadius.circular(design.space.radius),
      ),
      child: slot.you
          ? _HandFanView(fan: slot.hand!)
          : _Opponent(count: slot.count, label: slot.label),
    );
  }
}

class _Opponent extends StatelessWidget {
  const _Opponent({
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    final shown = math.min(count, 3);
    return Column(
      children: [
        Text(
          label.isEmpty ? '$count' : '$label  $count',
          style: design.type.label.copyWith(color: design.palette.muted),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < shown; i++)
                Transform.translate(
                  offset: Offset(design.space.xs * i, design.space.hair * i),
                  child: FractionallySizedBox(
                    widthFactor: 0.55,
                    heightFactor: 0.85,
                    child: const PlayingCard(visual: CardVisual.back()),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HandFanView extends StatelessWidget {
  const _HandFanView({required this.fan});

  final HandFan fan;

  @override
  Widget build(BuildContext context) {
    final n = fan.cards.length;
    if (n == 0) {
      return const SizedBox.expand();
    }
    return LayoutBuilder(
      builder: (context, box) {
        return MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              for (var i = 0; i < n; i++)
                _FannedCard(
                  index: i,
                  total: n,
                  visual: fan.cards[i],
                  width: box.maxWidth,
                  onPlay: fan.onPlay,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FannedCard extends StatelessWidget {
  const _FannedCard({
    required this.index,
    required this.total,
    required this.visual,
    required this.width,
    required this.onPlay,
  });

  final int index;
  final int total;
  final CardVisual visual;
  final double width;
  final ValueChanged<CardVisual> onPlay;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    final fan = FanRecipe.of(design.breakpoint);
    final t = total == 1 ? 0.5 : index / (total - 1);
    final angle = (t - 0.5) * fan.tilt;
    final dx = (t - 0.5) * width * fan.spread;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final delay = reduced ? 0.0 : (index / math.max(total, 1)) * 0.35;
    return TweenAnimationBuilder<double>(
      key: ValueKey(visual.id ?? visual.code),
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration: Motion.of(context, Motion.slow),
      curve: Interval(delay, 1, curve: Motion.curve),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(dx, (1 - value) * design.space.md),
            child: Transform.rotate(angle: angle, child: child),
          ),
        );
      },
      child: FractionallySizedBox(
        heightFactor: 0.92,
          child: PlayingCard(
          visual: visual,
          onPlay: (card) {
            if (card.playable) {
              HapticFeedback.mediumImpact();
              onPlay(card);
            }
          },
        ),
      ),
    );
  }
}

class _TrickView extends StatelessWidget {
  const _TrickView({required this.cluster});

  final TrickCluster cluster;

  @override
  Widget build(BuildContext context) {
    Alignment align(SeatVisual seat) => const TrickRecipe().align(seat);

    final space = DesignScope.of(context).space;
    Offset from(SeatVisual seat) {
      return switch (seat) {
        SeatVisual.south => Offset(0, space.xl),
        SeatVisual.north => Offset(0, -space.xl),
        SeatVisual.west => Offset(-space.xl, 0),
        SeatVisual.east => Offset(space.xl, 0),
      };
    }

    final reduced = MediaQuery.disableAnimationsOf(context);
    return Stack(
      children: [
        for (final play in cluster.plays)
          Align(
            alignment: align(play.seat),
            child: FractionallySizedBox(
              widthFactor: 0.38,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(play.card.id ?? play.card.code),
                tween: Tween(begin: reduced ? 1 : 0, end: 1),
                duration: Motion.of(context, Motion.medium),
                curve: Motion.curve,
                builder: (context, t, child) {
                  final o = from(play.seat) * (1 - t);
                  return Transform.translate(
                    offset: o,
                    child: Transform.rotate(
                      angle: (1 - t) * 0.2,
                      child: Opacity(opacity: t, child: child),
                    ),
                  );
                },
                child: PlayingCard(visual: play.card),
              ),
            ),
          ),
      ],
    );
  }
}
