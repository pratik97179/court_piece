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

  PlayingCard _card(
    ArtRank rank,
    ArtSuit suit,
    CardPresence presence, {
    CardScale scale = CardScale.trick,
  }) {
    return PlayingCard(
      art: art,
      view: CardView(
        id: CardArtId(rank: rank, suit: suit),
      ),
      presence: presence,
      scale: scale,
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
        north: SeatRail(
          scale: CardScale.opponent,
          cards: [
            _card(
              ArtRank.two,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.three,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.four,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.five,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.six,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
          ],
        ),
        west: SeatRail(
          axis: Axis.vertical,
          scale: CardScale.opponent,
          cards: [
            _card(
              ArtRank.seven,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.eight,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.nine,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.ten,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.jack,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
          ],
        ),
        east: SeatRail(
          axis: Axis.vertical,
          scale: CardScale.opponent,
          cards: [
            _card(
              ArtRank.queen,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.king,
              ArtSuit.clubs,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.two,
              ArtSuit.diamonds,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.three,
              ArtSuit.diamonds,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
            _card(
              ArtRank.four,
              ArtSuit.diamonds,
              CardPresence.facedown,
              scale: CardScale.opponent,
            ),
          ],
        ),
        south: SeatRail(
          scale: CardScale.hand,
          cards: [
            _card(
              ArtRank.ace,
              ArtSuit.hearts,
              CardPresence.idle,
              scale: CardScale.hand,
            ),
            _card(
              ArtRank.king,
              ArtSuit.diamonds,
              CardPresence.idle,
              scale: CardScale.hand,
            ),
            _card(
              ArtRank.queen,
              ArtSuit.spades,
              CardPresence.selected,
              scale: CardScale.hand,
            ),
            _card(
              ArtRank.jack,
              ArtSuit.hearts,
              CardPresence.idle,
              scale: CardScale.hand,
            ),
            _card(
              ArtRank.nine,
              ArtSuit.spades,
              CardPresence.idle,
              scale: CardScale.hand,
            ),
            _card(
              ArtRank.eight,
              ArtSuit.diamonds,
              CardPresence.idle,
              scale: CardScale.hand,
            ),
            _card(
              ArtRank.seven,
              ArtSuit.hearts,
              CardPresence.dimmed,
              scale: CardScale.hand,
            ),
          ],
        ),
        well: TrickWell(
          north: _card(ArtRank.three, ArtSuit.hearts, CardPresence.idle),
          west: _card(ArtRank.five, ArtSuit.hearts, CardPresence.idle),
          east: _card(ArtRank.six, ArtSuit.spades, CardPresence.idle),
          south: _card(ArtRank.ten, ArtSuit.spades, CardPresence.playable),
        ),
      ),
    );
  }
}
