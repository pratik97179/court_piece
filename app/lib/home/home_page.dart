import 'package:court_piece/design/design.dart';
import 'package:flutter/material.dart';

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
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
      body: CourtCluster(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                key: const ValueKey<String>('play-local'),
                onPressed: onPlayLocal,
                child: const Text('Play'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
