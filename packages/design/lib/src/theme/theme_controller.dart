import 'package:flutter/material.dart';

abstract class ThemeStore {
  Future<String?> read();
  Future<void> write(String value);
}

/// Persists and cycles light, dark, and system theme.
class ThemeController extends ChangeNotifier {
  ThemeController({required this.store});

  final ThemeStore store;
  ThemeMode mode = ThemeMode.system;

  Future<void> load() async {
    final raw = await store.read();
    mode = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode next) async {
    mode = next;
    notifyListeners();
    await store.write(switch (next) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  Future<void> cycle() {
    final next = switch (mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    return setMode(next);
  }
}
