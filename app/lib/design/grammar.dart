import 'package:court_piece/design/recipe.dart';
import 'package:court_piece/design/table.dart';
import 'package:court_piece/design/theme.dart';
import 'package:flutter/material.dart';

/// Page shell: optional header, clustered body or table.
class CourtScreen extends StatelessWidget {
  const CourtScreen({super.key, this.header, this.body, this.table})
    : assert((body == null) != (table == null));

  final CourtHeader? header;
  final CourtCluster? body;
  final GameTable? table;

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
                  Expanded(child: table ?? body!),
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
      padding: EdgeInsets.symmetric(
        horizontal: recipe.titleSize,
        vertical: recipe.titleSize * 0.18,
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
