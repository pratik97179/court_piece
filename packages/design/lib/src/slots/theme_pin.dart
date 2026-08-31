import 'package:flutter/material.dart';

class ThemePin {
  const ThemePin({required this.mode, required this.onCycle});

  final ThemeMode mode;
  final VoidCallback onCycle;
}
