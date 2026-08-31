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

  PlayingCard _card(ArtRank rank, ArtSuit suit, CardPresence presence) {
    return PlayingCard(
      art: art,
      view: CardView(
        id: CardArtId(rank: rank, suit: suit),
      ),
      presence: presence,
    );
  }

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
      table: GameTable(
        north: _card(ArtRank.ace, ArtSuit.spades, CardPresence.facedown),
        east: _card(ArtRank.king, ArtSuit.hearts, CardPresence.facedown),
        south: _card(ArtRank.queen, ArtSuit.diamonds, CardPresence.idle),
        west: _card(ArtRank.jack, ArtSuit.clubs, CardPresence.facedown),
        well: _card(ArtRank.ten, ArtSuit.spades, CardPresence.playable),
      ),
    );
  }
}
