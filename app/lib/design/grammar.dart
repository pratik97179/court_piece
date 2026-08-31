import 'package:court_piece/design/theme.dart';
import 'package:flutter/material.dart';

/// Page shell: optional header, clustered body.
class CourtScreen extends StatelessWidget {
  const CourtScreen({super.key, this.header, required this.body});

  final CourtHeader? header;
  final CourtCluster body;

  @override
  Widget build(BuildContext context) {
    final theme = CourtTheme.of(context);
    return Material(
      color: theme.felt,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(theme.inset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?header,
              if (header != null) SizedBox(height: theme.gap),
              Expanded(child: body),
            ],
          ),
        ),
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
    final theme = CourtTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (trailing != null) ...[SizedBox(width: theme.gap), trailing!],
      ],
    );
  }
}

enum CourtClusterAxis { vertical, horizontal }

/// Stacked children with theme gap.
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
    final gap = CourtTheme.of(context).gap;
    if (children.isEmpty) {
      return const SizedBox.expand();
    }
    return Flex(
      direction: axis == CourtClusterAxis.vertical
          ? Axis.vertical
          : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: gap, height: gap),
          children[i],
        ],
      ],
    );
  }
}
