import 'package:court_piece/design/theme.dart';
import 'package:flutter/material.dart';

/// Felt canvas.
class CourtScreen extends StatelessWidget {
  const CourtScreen({super.key, this.body});

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    return Material(
      color: theme.felt,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(theme.inset),
          child: body ?? const SizedBox.expand(),
        ),
      ),
    );
  }
}
