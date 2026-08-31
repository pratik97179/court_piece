import 'package:flutter/material.dart';

import '../foundation/metrics.dart';
import '../foundation/palette.dart';
import '../theme/app_theme.dart';

class HostShell extends StatelessWidget {
  const HostShell({super.key, required this.builder});

  final Widget Function(BuildContext context, DesignScope design) builder;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = dark ? Palette.dark : Palette.light;
    final space = Space.of(size);
    final scope = DesignScope(
      palette: palette,
      space: space,
      type: TypeScale(space),
      breakpoint: breakpointFor(size),
      child: Builder(builder: (context) {
        return builder(context, DesignScope.of(context));
      }),
    );
    return scope;
  }
}
