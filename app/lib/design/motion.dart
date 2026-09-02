import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

/// iOS-style push. Slide plus a short fade.
final class CourtPageTransitionsBuilder extends PageTransitionsBuilder {
  const CourtPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!CourtMotion.live(context)) {
      return child;
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.14, 0),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}

/// Named Apple springs. Callers never pick a raw duration.
abstract final class CourtMotion {
  static const Duration theme = Duration(milliseconds: 520);

  static const Duration crossfade = Duration(milliseconds: 420);

  static const Duration beat = Duration(milliseconds: 420);

  /// Stagger between cards during deal-in.
  static const Duration dealSlot = Duration(milliseconds: 22);

  /// Pause after the fourth card lands, before cards collect to the winner.
  static const Duration trickBeat = Duration(milliseconds: 480);

  static const Duration collectBeat = Duration(milliseconds: 480);

  /// Pause after cards reach the winner, before the next turn.
  static const Duration afterCollectBeat = Duration(milliseconds: 420);

  static Motion play(BuildContext context) {
    return live(context)
        ? const CupertinoMotion.snappy(snapToEnd: true)
        : const Motion.none();
  }

  static Motion deal(BuildContext context) {
    return live(context)
        ? const CupertinoMotion.smooth(snapToEnd: true)
        : const Motion.none();
  }

  static Motion overlay(BuildContext context) {
    return live(context)
        ? const CupertinoMotion.smooth(snapToEnd: true)
        : const Motion.none();
  }

  static Motion collect(BuildContext context) {
    return live(context)
        ? const CupertinoMotion.smooth(snapToEnd: true)
        : const Motion.none();
  }

  static bool live(BuildContext context) {
    return !MediaQuery.disableAnimationsOf(context);
  }

  /// Wait for the last staggered deal-in card, then one beat.
  static Duration dealIn(int count) {
    if (count <= 0) {
      return beat;
    }
    return dealSlot * (count - 1) + beat;
  }
}

/// Felt fade plus a slight scale. Uses opacity and transform only.
class CourtReveal extends StatelessWidget {
  const CourtReveal({super.key, required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleMotionBuilder(
      motion: CourtMotion.overlay(context),
      value: visible ? 1 : 0,
      from: 0,
      builder: (context, value, child) {
        final t = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.94 + (0.06 * t), child: child),
        );
      },
      child: child,
    );
  }
}

/// Flies a card from [from] into [to]. Uses transform only.
class CourtFlight extends StatelessWidget {
  const CourtFlight({
    super.key,
    required this.from,
    required this.to,
    required this.child,
    this.visible = true,
    this.onFinished,
  });

  final Alignment from;
  final Alignment to;
  final Widget child;
  final bool visible;
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context) {
    if (!CourtMotion.live(context)) {
      if (onFinished != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onFinished!());
      }
      return visible
          ? Align(alignment: to, child: child)
          : const SizedBox.shrink();
    }
    return SingleMotionBuilder(
      motion: CourtMotion.play(context),
      value: visible ? 1 : 0,
      from: visible ? 0 : 1,
      onAnimationStatusChanged: (status) {
        if (status == AnimationStatus.completed && visible) {
          onFinished?.call();
        }
      },
      builder: (context, value, child) {
        final t = value.clamp(0.0, 1.0);
        return Align(
          alignment: Alignment.lerp(from, to, t)!,
          child: Opacity(
            opacity: t,
            child: Transform.scale(scale: 1.22 - (0.22 * t), child: child),
          ),
        );
      },
      child: child,
    );
  }
}

/// Cards slide toward [toward] while fading out.
class CourtCollect extends StatelessWidget {
  const CourtCollect({
    super.key,
    required this.from,
    required this.toward,
    required this.child,
    this.onFinished,
  });

  final Alignment from;
  final Alignment toward;
  final Widget child;
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context) {
    if (!CourtMotion.live(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onFinished?.call());
      return const SizedBox.shrink();
    }
    return SingleMotionBuilder(
      motion: CourtMotion.collect(context),
      value: 1,
      from: 0,
      onAnimationStatusChanged: (status) {
        if (status == AnimationStatus.completed) {
          onFinished?.call();
        }
      },
      builder: (context, value, child) {
        final t = value.clamp(0.0, 1.0);
        return Align(
          alignment: Alignment.lerp(from, toward, t)!,
          child: Opacity(opacity: 1 - t, child: child),
        );
      },
      child: child,
    );
  }
}

/// First appearance of a card. Stagger comes from [slot].
class CourtEnter extends StatelessWidget {
  const CourtEnter({super.key, required this.child, this.slot = 0});

  final Widget child;
  final int slot;

  @override
  Widget build(BuildContext context) {
    if (!CourtMotion.live(context)) {
      return child;
    }
    return _DelayedEnter(slot: slot, child: child);
  }
}

class _DelayedEnter extends StatefulWidget {
  const _DelayedEnter({required this.slot, required this.child});

  final int slot;
  final Widget child;

  @override
  State<_DelayedEnter> createState() => _DelayedEnterState();
}

class _DelayedEnterState extends State<_DelayedEnter> {
  var _on = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final wait = widget.slot * CourtMotion.dealSlot.inMilliseconds;
    if (wait <= 0) {
      _on = true;
      return;
    }
    _timer = Timer(Duration(milliseconds: wait), () {
      if (mounted) {
        setState(() {
          _on = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleMotionBuilder(
      motion: CourtMotion.deal(context),
      value: _on ? 1 : 0,
      from: 0,
      builder: (context, value, child) {
        final t = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.96 + (0.04 * t), child: child),
        );
      },
      child: widget.child,
    );
  }
}
