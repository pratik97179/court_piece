import 'package:court_piece/design/design.dart';
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onPlayLocal,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onPlayLocal;

  @override
  Widget build(BuildContext context) {
    return CourtScreen(
      header: CourtHeader(
        title: 'Court Piece',
        trailing: IconButton(
          key: const ValueKey<String>('theme-toggle'),
          tooltip: 'Toggle theme',
          onPressed: onToggleTheme,
          icon: AnimatedSwitcher(
            duration: CourtMotion.crossfade,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.82, end: 1).animate(animation),
                  child: child,
                ),
              );
            },
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey<bool>(isDark),
            ),
          ),
        ),
      ),
      body: CourtCluster(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_PlayButton(onPressed: onPlayLocal)],
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  var _down = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: SingleMotionBuilder(
        motion: CourtMotion.play(context),
        value: _down ? 0.96 : 1,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: TextButton(
          key: const ValueKey<String>('play-local'),
          onPressed: widget.onPressed,
          child: const Text('Play'),
        ),
      ),
    );
  }
}
