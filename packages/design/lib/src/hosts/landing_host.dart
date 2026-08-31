import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/motion.dart';
import '../recipes/layout.dart';
import '../slots/landing_action.dart';
import '../slots/theme_pin.dart';
import '../theme/app_theme.dart';
import 'host_shell.dart';

class LandingHost extends StatelessWidget {
  const LandingHost({
    super.key,
    required this.title,
    required this.actions,
    this.field,
    this.trailing,
    this.overlay,
  });

  final String title;
  final List<LandingAction> actions;
  final LandingField? field;
  final ThemePin? trailing;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return HostShell(
      builder: (context, design) {
        final recipe = LandingRecipe.of(design.breakpoint);
        return Material(
          color: design.palette.felt,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: trailing == null
                      ? const SizedBox.shrink()
                      : _ThemePinButton(pin: trailing!),
                ),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: recipe.widthFactor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: design.space.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: design.type.display.copyWith(color: design.palette.ink),
                          ),
                          SizedBox(height: design.space.xl),
                          if (field != null) ...[
                            _NameField(field: field!),
                            SizedBox(height: design.space.lg),
                          ],
                          for (final action in actions) ...[
                            _LandingButton(action: action),
                            SizedBox(height: design.space.sm),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (overlay != null) Positioned.fill(child: overlay!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemePinButton extends StatelessWidget {
  const _ThemePinButton({required this.pin});

  final ThemePin pin;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    final icon = switch (pin.mode) {
      ThemeMode.system => Icons.tonality,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
    return IconButton(
      onPressed: pin.onCycle,
      icon: Icon(icon, color: design.palette.ink),
    );
  }
}

class _NameField extends StatefulWidget {
  const _NameField({required this.field});

  final LandingField field;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.field.value);

  @override
  void didUpdateWidget(_NameField old) {
    super.didUpdateWidget(old);
    if (old.field.value != widget.field.value &&
        _controller.text != widget.field.value) {
      _controller.text = widget.field.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    return TextField(
      controller: _controller,
      onChanged: widget.field.onChanged,
      cursorColor: design.palette.accent,
      style: design.type.body.copyWith(color: design.palette.ink),
      decoration: InputDecoration(
        hintText: widget.field.hint,
        hintStyle: design.type.body.copyWith(color: design.palette.muted),
        filled: true,
        fillColor: design.palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(design.space.radius),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: design.space.md,
          vertical: design.space.sm,
        ),
      ),
    );
  }
}

class _LandingButton extends StatefulWidget {
  const _LandingButton({required this.action});

  final LandingAction action;

  @override
  State<_LandingButton> createState() => _LandingButtonState();
}

class _LandingButtonState extends State<_LandingButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final design = DesignScope.of(context);
    final primary = widget.action.kind == ActionKind.primary;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        HapticFeedback.lightImpact();
        widget.action.onSelect();
      },
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: Motion.of(context, Motion.fast),
        curve: Motion.curve,
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.fast),
          curve: Motion.curve,
          padding: EdgeInsets.symmetric(vertical: design.space.md),
          decoration: BoxDecoration(
            color: primary ? design.palette.accent : design.palette.surface,
            borderRadius: BorderRadius.circular(design.space.radius),
          ),
          child: Text(
            widget.action.label,
            textAlign: TextAlign.center,
            style: design.type.title.copyWith(
              color: primary ? design.palette.onAccent : design.palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}
