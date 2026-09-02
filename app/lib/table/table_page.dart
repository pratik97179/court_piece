import 'dart:async';

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
  Card? _lifted;
  List<TablePlay> _wellPlays = const [];
  Seat? _collectWinner;
  Seat? _pendingCollectWinner;
  var _awaitingCollect = false;
  var _paceLocked = false;
  Timer? _paceTimer;

  PausableGameSession? get _pausable =>
      widget.session is PausableGameSession
      ? widget.session as PausableGameSession
      : null;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onView);
    _wellPlays = widget.session.view.trick;
  }

  @override
  void dispose() {
    _paceTimer?.cancel();
    widget.session.removeListener(_onView);
    widget.session.dispose();
    super.dispose();
  }

  void _pauseActing() {
    _paceLocked = true;
    _pausable?.setActingPaused(true);
  }

  void _resumeActing() {
    if (!_paceLocked) {
      return;
    }
    _paceLocked = false;
    _pausable?.setActingPaused(false);
  }

  void _onView() {
    final view = widget.session.view;
    final hand = view.southHand;
    if (_lifted != null && !hand.contains(_lifted)) {
      _lifted = null;
    }
    for (final event in widget.session.takeEvents()) {
      if (event is TableTrickWon) {
        _wellPlays = event.plays;
        _pendingCollectWinner = event.winner;
        _awaitingCollect = true;
        _pauseActing();
      }
    }
    if (_collectWinner == null && !_awaitingCollect) {
      final viewTrick = view.trick;
      if (viewTrick.length > _wellPlays.length) {
        _wellPlays = viewTrick;
        _pauseActing();
      } else if (!_paceLocked) {
        _wellPlays = viewTrick;
      }
    }
    setState(() {});
  }

  void _onWellCardLanded() {
    if (!_paceLocked && !_awaitingCollect) {
      return;
    }
    _paceTimer?.cancel();
    if (_awaitingCollect && _wellPlays.length == 4) {
      _paceTimer = Timer(CourtMotion.trickBeat, () {
        if (!mounted || !_awaitingCollect) {
          return;
        }
        setState(() {
          _collectWinner = _pendingCollectWinner;
          _pendingCollectWinner = null;
          _awaitingCollect = false;
        });
      });
      return;
    }
    _paceTimer = Timer(CourtMotion.beat, () {
      if (!mounted) {
        return;
      }
      _resumeActing();
      setState(() {});
    });
  }

  void _onTrickCollected() {
    _paceTimer?.cancel();
    setState(() {
      _collectWinner = null;
      _wellPlays = widget.session.view.trick;
    });
    _paceTimer = Timer(CourtMotion.afterCollectBeat, () {
      if (!mounted) {
        return;
      }
      _resumeActing();
      setState(() {});
    });
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
      overlay: _overlay(view),
      table: GameTable(
        score: ScorePips(
          northSouthTricks: view.northSouthTricks,
          eastWestTricks: view.eastWestTricks,
          northSouthCourts: view.northSouthCourts,
          eastWestCourts: view.eastWestCourts,
        ),
        trump: view.phase == TablePhase.playing && view.trump != null
            ? TrumpMark(suit: view.trump!)
            : null,
        north: OpponentSeat(
          seat: Seat.north,
          count: view.northCount,
          art: widget.art,
        ),
        east: OpponentSeat(
          seat: Seat.east,
          count: view.eastCount,
          art: widget.art,
        ),
        west: OpponentSeat(
          seat: Seat.west,
          count: view.westCount,
          art: widget.art,
        ),
        south: SeatRail(
          key: const ValueKey<String>('south-rail'),
          scale: CardScale.hand,
          cards: [
            for (final card in view.southHand)
              PlayingCard(
                art: widget.art,
                view: CardView(id: _artId(card)),
                presence: _handPresence(view, card),
                scale: CardScale.hand,
                onTap: () => _onSouthTap(view, card),
              ),
          ],
        ),
        well: TrickWell(
          north: _wellCard(Seat.north),
          east: _wellCard(Seat.east),
          west: _wellCard(Seat.west),
          south: _wellCard(Seat.south),
          collectWinner: _collectWinner,
          onCollected: _onTrickCollected,
          onCardLanded: _onWellCardLanded,
        ),
      ),
    );
  }

  void _onSouthTap(TableView view, Card card) {
    setState(() => _lifted = card);
    if (!_southPlays(view) || !view.legalSouth.contains(card)) {
      return;
    }
    _pauseActing();
    widget.session.submit(PlayCardIntent(card));
  }

  CourtOverlay? _overlay(TableView view) {
    if (view.phase == TablePhase.matchOver) {
      return _matchOverlay(view);
    }
    if (view.phase == TablePhase.dealOver) {
      return _dealOverlay(view);
    }
    return _trumpOverlay(view);
  }

  CourtOverlay? _dealOverlay(TableView view) {
    final winner = view.dealWinner;
    if (winner == null) {
      return null;
    }
    final title = view.dealCourt ? 'Court' : 'Deal over';
    return CourtOverlay(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _teamWonLabel(winner),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextButton(
            key: const ValueKey<String>('next-deal'),
            onPressed: () {
              widget.session.submit(const StartDealIntent());
            },
            child: const Text('Next deal'),
          ),
        ],
      ),
    );
  }

  CourtOverlay? _matchOverlay(TableView view) {
    final winner = view.matchWinner;
    if (winner == null) {
      return null;
    }
    return CourtOverlay(
      title: 'Match won',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _teamWonLabel(winner),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextButton(
            key: const ValueKey<String>('leave-match'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _teamWonLabel(Team team) {
    return switch (team) {
      Team.northSouth => 'Your team wins',
      Team.eastWest => 'Opponents win',
    };
  }

  CourtOverlay? _trumpOverlay(TableView view) {
    if (view.phase != TablePhase.waitingTrump || view.toAct != Seat.south) {
      return null;
    }
    return CourtOverlay(
      title: 'Name trump',
      child: Row(
        children: [
          for (final suit in Suit.values)
            Expanded(
              child: _TrumpSuit(
                suit: suit,
                onPick: () {
                  widget.session.submit(CallTrumpIntent(suit));
                },
              ),
            ),
        ],
      ),
    );
  }

  CardPresence _handPresence(TableView view, Card card) {
    if (_lifted == card) {
      return CardPresence.selected;
    }
    if (!_southPlays(view)) {
      return CardPresence.idle;
    }
    return view.legalSouth.contains(card)
        ? CardPresence.playable
        : CardPresence.dimmed;
  }

  bool _southPlays(TableView view) {
    return view.phase == TablePhase.playing &&
        view.toAct == Seat.south &&
        view.legalSouth.isNotEmpty &&
        !_paceLocked;
  }

  PlayingCard? _wellCard(Seat seat) {
    for (final play in _wellPlays) {
      if (play.seat == seat) {
        return PlayingCard(
          key: ValueKey<String>('well-${play.seat.name}-${play.card.code}'),
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

class _TrumpSuit extends StatelessWidget {
  const _TrumpSuit({required this.suit, required this.onPick});

  final Suit suit;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    final recipe = CourtScope.of(context).recipe;
    final red = suit == Suit.hearts || suit == Suit.diamonds;
    return InkWell(
      key: ValueKey<String>('trump-${suit.name}'),
      onTap: onPick,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: recipe.titleSize * 0.35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _suitMark(suit),
              style: TextStyle(
                color: red ? theme.accent : theme.ink,
                fontSize: recipe.titleSize * 1.7,
                height: 1,
              ),
            ),
            SizedBox(height: recipe.titleSize * 0.28),
            Text(
              _suitLabel(suit),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: theme.muted),
            ),
          ],
        ),
      ),
    );
  }
}

String _suitMark(Suit suit) {
  return switch (suit) {
    Suit.clubs => '\u2663',
    Suit.diamonds => '\u2666',
    Suit.hearts => '\u2665',
    Suit.spades => '\u2660',
  };
}

String _suitLabel(Suit suit) {
  return switch (suit) {
    Suit.clubs => 'Clubs',
    Suit.diamonds => 'Diamonds',
    Suit.hearts => 'Hearts',
    Suit.spades => 'Spades',
  };
}
