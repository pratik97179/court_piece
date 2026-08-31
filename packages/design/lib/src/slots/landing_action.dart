import 'package:flutter/foundation.dart';

enum ActionKind { primary, secondary, tertiary }

class LandingAction {
  const LandingAction._(this.kind, this.label, this.onSelect);

  const LandingAction.primary({required String label, required VoidCallback onSelect})
    : this._(ActionKind.primary, label, onSelect);

  const LandingAction.secondary({required String label, required VoidCallback onSelect})
    : this._(ActionKind.secondary, label, onSelect);

  const LandingAction.tertiary({required String label, required VoidCallback onSelect})
    : this._(ActionKind.tertiary, label, onSelect);

  final ActionKind kind;
  final String label;
  final VoidCallback onSelect;
}

class LandingField {
  const LandingField({
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
}
