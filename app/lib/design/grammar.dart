import 'package:court_piece/design/motion.dart';
import 'package:court_piece/design/recipe.dart';
import 'package:court_piece/design/table.dart';
import 'package:court_piece/design/theme.dart';
import 'package:flutter/material.dart';

/// Page shell: optional header, clustered body or table.
class CourtScreen extends StatelessWidget {
  const CourtScreen({
    super.key,
    this.header,
    this.body,
    this.table,
    this.overlay,
  }) : assert((body == null) != (table == null));

  final CourtHeader? header;
  final CourtCluster? body;
  final GameTable? table;
  final CourtOverlay? overlay;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    return Material(
      color: theme.felt,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final breakpoint = CourtRecipe.resolve(constraints);
          final recipe = CourtRecipe.forBreakpoint(breakpoint);
          return CourtScope(
            breakpoint: breakpoint,
            recipe: recipe,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?header,
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        table ?? body!,
                        _OverlayLane(overlay: overlay),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Top slot: title plus optional trailing action.
class CourtHeader extends StatelessWidget {
  const CourtHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final recipe = CourtScope.of(context).recipe;
    final theme = CourtTheme.of(context);
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: recipe.titleSize,
      color: theme.muted,
      fontWeight: FontWeight.w400,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        recipe.titleSize * 0.7,
        recipe.titleSize * 0.06,
        recipe.titleSize * 0.5,
        recipe.titleSize * 0.06,
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: titleStyle)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Covers the table slot with felt and a surface plate. Not a route.
class CourtOverlay extends StatelessWidget {
  const CourtOverlay({super.key, required this.child, this.title});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    final recipe = CourtScope.of(context).recipe;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: recipe.titleSize,
      color: theme.muted,
      fontWeight: FontWeight.w400,
    );
    return ColoredBox(
      color: theme.felt,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.88,
          child: Material(
            color: theme.surface,
            elevation: 1,
            shadowColor: theme.ink.withValues(alpha: 0.28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(recipe.titleSize * 0.35),
              side: BorderSide(color: theme.ink.withValues(alpha: 0.06)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                recipe.titleSize * 0.55,
                recipe.titleSize,
                recipe.titleSize * 0.55,
                recipe.titleSize * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) Text(title!, style: titleStyle),
                  if (title != null) SizedBox(height: recipe.titleSize * 0.7),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayLane extends StatefulWidget {
  const _OverlayLane({this.overlay});

  final CourtOverlay? overlay;

  @override
  State<_OverlayLane> createState() => _OverlayLaneState();
}

class _OverlayLaneState extends State<_OverlayLane> {
  CourtOverlay? _held;

  @override
  void initState() {
    super.initState();
    _held = widget.overlay;
  }

  @override
  void didUpdateWidget(_OverlayLane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overlay != null) {
      _held = widget.overlay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.overlay ?? _held;
    final visible = widget.overlay != null;
    if (shown == null) {
      return const Positioned(
        left: 0,
        top: 0,
        width: 0,
        height: 0,
        child: SizedBox.shrink(),
      );
    }
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: CourtReveal(visible: visible, child: shown),
      ),
    );
  }
}

enum CourtClusterAxis { vertical, horizontal }

/// Children share the flex axis equally.
class CourtCluster extends StatelessWidget {
  const CourtCluster({
    super.key,
    this.axis = CourtClusterAxis.vertical,
    required this.children,
  });

  final CourtClusterAxis axis;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.expand();
    }
    final vertical = axis == CourtClusterAxis.vertical;
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      children: [for (final child in children) Expanded(child: child)],
    );
  }
}
