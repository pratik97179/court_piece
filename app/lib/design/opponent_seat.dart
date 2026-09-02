import 'dart:math' as math;

import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/design/card_fan.dart';
import 'package:court_piece/design/playing_card.dart';
import 'package:court_piece/design/recipe.dart';
import 'package:court_piece/design/table.dart';
import 'package:court_piece/design/theme.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter/material.dart';

/// Opponent seat: avatar, count, and a compact fanned pile of card backs.
class OpponentSeat extends StatelessWidget {
  const OpponentSeat({
    super.key,
    required this.seat,
    required this.count,
    required this.art,
  });

  final Seat seat;
  final int count;
  final CardArt art;

  @override
  Widget build(BuildContext context) {
    final module = TableScope.maybeOf(context)!;
    final breakpoint = CourtScope.of(context).breakpoint;
    final fan = _fanSpec(module, breakpoint);
    final pile = CardFan(
      spec: fan,
      count: count,
      cardBuilder: (i) => PlayingCard(
        key: ValueKey<String>('${seat.name}-$i'),
        art: art,
        view: const CardView(
          id: CardArtId(rank: ArtRank.ace, suit: ArtSuit.clubs),
        ),
        presence: CardPresence.facedown,
        scale: CardScale.opponent,
      ),
    );
    final identity = _SeatIdentity(seat: seat, count: count);
    final gap = module.gap * 0.45;
    return switch (seat) {
      Seat.north => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          identity,
          SizedBox(height: gap),
          pile,
        ],
      ),
      Seat.west => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          identity,
          SizedBox(width: gap),
          pile,
        ],
      ),
      Seat.east => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pile,
          SizedBox(width: gap),
          identity,
        ],
      ),
      Seat.south => pile,
    };
  }

  FanSpec _fanSpec(TableModule module, CourtBreakpoint breakpoint) {
    final rotation = switch (seat) {
      Seat.north => 0.0,
      Seat.west => -math.pi / 2,
      Seat.east => math.pi / 2,
      Seat.south => 0.0,
    };
    return FanSpec(
      cardWidth: module.opponentWidth,
      overlap: module.opponentOverlap,
      arc: switch (breakpoint) {
        CourtBreakpoint.compact => 0.18,
        CourtBreakpoint.medium => 0.16,
        CourtBreakpoint.expanded => 0.14,
      },
      tilt: switch (breakpoint) {
        CourtBreakpoint.compact => 0.16,
        CourtBreakpoint.medium => 0.14,
        CourtBreakpoint.expanded => 0.12,
      },
      rotation: rotation,
      maxAlong: module.opponentFanAlong,
      pivot: Alignment.bottomCenter,
    );
  }
}

class _SeatIdentity extends StatelessWidget {
  const _SeatIdentity({required this.seat, required this.count});

  final Seat seat;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    final module = TableScope.maybeOf(context);
    final size = module?.avatarSize ?? 22;
    final letter = switch (seat) {
      Seat.north => 'N',
      Seat.east => 'E',
      Seat.west => 'W',
      Seat.south => 'S',
    };
    final vertical = seat == Seat.west || seat == Seat.east;
    final avatar = SizedBox(
      key: ValueKey<String>('${seat.name}-avatar'),
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.ink.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: theme.muted,
              fontSize: size * 0.42,
              height: 1,
            ),
          ),
        ),
      ),
    );
    final label = Text(
      '$count',
      key: ValueKey<String>('${seat.name}-count'),
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: theme.muted, height: 1),
    );
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          SizedBox(height: size * 0.18),
          label,
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        SizedBox(width: size * 0.22),
        label,
      ],
    );
  }
}
