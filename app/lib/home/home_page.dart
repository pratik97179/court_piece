import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/design/design.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.art,
    required this.isDark,
    required this.onToggleTheme,
  });

  final CardArt art;
  final bool isDark;
  final VoidCallback onToggleTheme;

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
        axis: CourtClusterAxis.horizontal,
        children: [
          PlayingCard(
            art: art,
            view: const CardView(
              id: CardArtId(rank: ArtRank.ace, suit: ArtSuit.spades),
            ),
            presence: CardPresence.idle,
          ),
          PlayingCard(
            art: art,
            view: const CardView(
              id: CardArtId(rank: ArtRank.king, suit: ArtSuit.hearts),
            ),
            presence: CardPresence.playable,
          ),
          PlayingCard(
            art: art,
            view: const CardView(
              id: CardArtId(rank: ArtRank.queen, suit: ArtSuit.diamonds),
            ),
            presence: CardPresence.selected,
          ),
          PlayingCard(
            art: art,
            view: const CardView(
              id: CardArtId(rank: ArtRank.jack, suit: ArtSuit.clubs),
            ),
            presence: CardPresence.facedown,
          ),
        ],
      ),
    );
  }
}
