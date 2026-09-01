import 'dart:math';

import 'package:court_piece/application/game_session.dart';
import 'package:court_piece/design/design.dart';
import 'package:court_piece/home/home_page.dart';
import 'package:court_piece/infrastructure/heuristic_cpu.dart';
import 'package:court_piece/infrastructure/local_cpu_session.dart';
import 'package:court_piece/infrastructure/svg_card_art.dart';
import 'package:court_piece/table/table_page.dart';
import 'package:flutter/material.dart';

class CourtApp extends StatefulWidget {
  const CourtApp({super.key, this.createLocalSession});

  final GameSession Function()? createLocalSession;

  @override
  State<CourtApp> createState() => _CourtAppState();
}

class _CourtAppState extends State<CourtApp> {
  ThemeMode _mode = ThemeMode.system;
  final _art = const SvgCardArt();

  bool _isDark(BuildContext context) {
    return switch (_mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
  }

  void _toggleTheme(BuildContext context) {
    setState(() {
      _mode = _isDark(context) ? ThemeMode.light : ThemeMode.dark;
    });
  }

  GameSession _newLocalSession() {
    return widget.createLocalSession?.call() ??
        LocalCpuSession(
          cpu: const HeuristicCpu(),
          seed: Random().nextInt(1 << 30),
        );
  }

  void _playLocal(BuildContext context) {
    final session = _newLocalSession();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TablePage(session: session, art: _art),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Court Piece',
      debugShowCheckedModeBanner: false,
      theme: CourtTheme.light().asMaterial(),
      darkTheme: CourtTheme.dark().asMaterial(),
      themeMode: _mode,
      home: Builder(
        builder: (context) {
          return HomePage(
            isDark: _isDark(context),
            onToggleTheme: () => _toggleTheme(context),
            onPlayLocal: () => _playLocal(context),
          );
        },
      ),
    );
  }
}
