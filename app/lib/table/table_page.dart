import 'package:court_piece/application/card_art.dart';
import 'package:court_piece/application/game_session.dart';
import 'package:court_piece/design/design.dart';
import 'package:court_piece/domain/card.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter/material.dart' hide Card;

/// Renders [TableView]. Owns the [GameSession] for this route.
class TablePage extends StatefulWidget {
  const TablePage({super.key, required this.session, required this.art});

  final GameSession session;
  final CardArt art;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onView);
  }

  @override
  void dispose() {
    widget.session.removeListener(_onView);
    widget.session.dispose();
    super.dispose();
  }

  void _onView() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.session.view;
    return CourtScreen(
      header: CourtHeader(
        title: 'Court Piece',
        trailing: IconButton(
          key: const ValueKey<String>('leave-table'),
          tooltip: 'Leave',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      table: GameTable(
        north: _backs(Seat.north, view.northCount),
        east: _backs(Seat.east, view.eastCount, axis: Axis.vertical),
        west: _backs(Seat.west, view.westCount, axis: Axis.vertical),
        south: SeatRail(
          scale: CardScale.hand,
          cards: [
            for (final card in view.southHand)
              PlayingCard(
                art: widget.art,
                view: CardView(id: _artId(card)),
                presence: CardPresence.idle,
                scale: CardScale.hand,
              ),
          ],
        ),
        well: TrickWell(
          north: _trick(view, Seat.north),
          east: _trick(view, Seat.east),
          west: _trick(view, Seat.west),
          south: _trick(view, Seat.south),
        ),
      ),
    );
  }

  SeatRail _backs(Seat seat, int count, {Axis axis = Axis.horizontal}) {
    return SeatRail(
      axis: axis,
      scale: CardScale.opponent,
      cards: [
        for (var i = 0; i < count; i++)
          PlayingCard(
            key: ValueKey<String>('${seat.name}-$i'),
            art: widget.art,
            view: const CardView(
              id: CardArtId(rank: ArtRank.ace, suit: ArtSuit.clubs),
            ),
            presence: CardPresence.facedown,
            scale: CardScale.opponent,
          ),
      ],
    );
  }

  PlayingCard? _trick(TableView view, Seat seat) {
    for (final play in view.trick) {
      if (play.seat == seat) {
        return PlayingCard(
          art: widget.art,
          view: CardView(id: _artId(play.card)),
          presence: CardPresence.idle,
        );
      }
    }
    return null;
  }
}

CardArtId _artId(Card card) {
  return CardArtId(
    rank: ArtRank.values[card.rank.index],
    suit: ArtSuit.values[card.suit.index],
  );
}
