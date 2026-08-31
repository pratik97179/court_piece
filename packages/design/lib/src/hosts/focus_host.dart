import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../recipes/layout.dart';
import '../slots/choice_group.dart';
import '../slots/landing_action.dart';
import '../slots/lobby_seats.dart';
import '../theme/app_theme.dart';
import 'host_shell.dart';

class FocusHost extends StatelessWidget {
  const FocusHost._({
    required this.title,
    this.body,
    this.group,
    this.action,
    this.code,
    this.onCopy,
    this.fieldHint,
    this.onSubmit,
    this.submitLabel,
    this.lobby,
  });

  factory FocusHost.choice({
    required String title,
    required ChoiceGroup group,
  }) {
    return FocusHost._(title: title, group: group);
  }

  factory FocusHost.message({
    required String title,
    required String body,
    required LandingAction action,
  }) {
    return FocusHost._(title: title, body: body, action: action);
  }

  factory FocusHost.roomCode({
    required String title,
    required String code,
    VoidCallback? onCopy,
    required LandingAction action,
  }) {
    return FocusHost._(title: title, code: code, onCopy: onCopy, action: action);
  }

  factory FocusHost.form({
    required String title,
    required String fieldHint,
    required ValueChanged<String> onSubmit,
    String submitLabel = 'Join',
  }) {
    return FocusHost._(
      title: title,
      fieldHint: fieldHint,
      onSubmit: onSubmit,
      submitLabel: submitLabel,
    );
  }

  factory FocusHost.lobby({
    required String title,
    required LobbySeats lobby,
  }) {
    return FocusHost._(title: title, lobby: lobby);
  }

  final String title;
  final String? body;
  final ChoiceGroup? group;
  final LandingAction? action;
  final String? code;
  final VoidCallback? onCopy;
  final String? fieldHint;
  final ValueChanged<String>? onSubmit;
  final String? submitLabel;
  final LobbySeats? lobby;

  @override
  Widget build(BuildContext context) {
    return HostShell(
      builder: (context, design) {
        final recipe = OverlayRecipe.of(design.breakpoint);
        return Material(
          color: design.palette.scrim,
          child: SafeArea(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: recipe.widthFactor,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: design.palette.surface,
                    borderRadius: BorderRadius.circular(design.space.radius),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(design.space.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: design.type.title.copyWith(color: design.palette.ink),
                        ),
                        SizedBox(height: design.space.md),
                        if (body != null)
                          Text(
                            body!,
                            textAlign: TextAlign.center,
                            style: design.type.body.copyWith(color: design.palette.muted),
                          ),
                        if (code != null) _Code(code: code!, onCopy: onCopy),
                        if (lobby != null) _Lobby(lobby: lobby!),
                        if (group != null) _Choices(group: group!),
                        if (fieldHint != null && onSubmit != null)
                          _JoinField(hint: fieldHint!, onSubmit: onSubmit!, label: submitLabel!),
                        if (action != null) ...[
                          SizedBox(height: design.space.md),
                          _FocusAction(action: action!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Code extends StatelessWidget {
  const _Code({required this.code, this.onCopy});

  final String code;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Clipboard.setData(ClipboardData(text: code));
        onCopy?.call();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: design.space.md),
        child: Text(
          code,
          textAlign: TextAlign.center,
          style: design.type.display.copyWith(
            color: design.palette.accent,
            letterSpacing: design.space.xs,
          ),
        ),
      ),
    );
  }
}

class _Lobby extends StatelessWidget {
  const _Lobby({required this.lobby});

  final LobbySeats lobby;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Code(code: lobby.code),
        for (var i = 0; i < lobby.names.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: design.space.xs),
            child: Text(
              lobby.names[i].isEmpty ? 'Seat ${i + 1}' : lobby.names[i],
              textAlign: TextAlign.center,
              style: design.type.body.copyWith(
                color: lobby.names[i].isEmpty
                    ? design.palette.muted
                    : design.palette.ink,
              ),
            ),
          ),
      ],
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({required this.group});

  final ChoiceGroup group;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: design.space.sm,
      runSpacing: design.space.sm,
      children: [
        for (final option in group.options)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              group.onSelect(option.id);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: design.palette.felt,
                borderRadius: BorderRadius.circular(design.space.radius),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: design.space.md,
                  vertical: design.space.sm,
                ),
                child: Text(
                  option.label,
                  style: design.type.title.copyWith(color: design.palette.ink),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _JoinField extends StatefulWidget {
  const _JoinField({
    required this.hint,
    required this.onSubmit,
    required this.label,
  });

  final String hint;
  final ValueChanged<String> onSubmit;
  final String label;

  @override
  State<_JoinField> createState() => _JoinFieldState();
}

class _JoinFieldState extends State<_JoinField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          cursorColor: design.palette.accent,
          style: design.type.body.copyWith(color: design.palette.ink),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: design.type.body.copyWith(color: design.palette.muted),
            filled: true,
            fillColor: design.palette.felt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(design.space.radius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: design.space.md),
        _FocusAction(
          action: LandingAction.primary(
            label: widget.label,
            onSelect: () => widget.onSubmit(_controller.text.trim()),
          ),
        ),
      ],
    );
  }
}

class _FocusAction extends StatelessWidget {
  const _FocusAction({required this.action});

  final LandingAction action;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return GestureDetector(
      onTap: action.onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: design.palette.accent,
          borderRadius: BorderRadius.circular(design.space.radius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: design.space.md),
          child: Text(
            action.label,
            textAlign: TextAlign.center,
            style: design.type.title.copyWith(color: design.palette.onAccent),
          ),
        ),
      ),
    );
  }
}
