import 'package:court_piece/design/design.dart';
import 'package:court_piece/home/home_page.dart';
import 'package:flutter/material.dart';

class CourtApp extends StatefulWidget {
  const CourtApp({super.key});

  @override
  State<CourtApp> createState() => _CourtAppState();
}

class _CourtAppState extends State<CourtApp> {
  ThemeMode _mode = ThemeMode.system;

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
          );
        },
      ),
    );
  }
}
