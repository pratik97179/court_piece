import 'package:flutter/foundation.dart';

class ChoiceOption {
  const ChoiceOption({required this.id, required this.label, this.subtitle = ''});

  final String id;
  final String label;
  final String subtitle;
}

class ChoiceGroup {
  const ChoiceGroup({required this.options, required this.onSelect});

  final List<ChoiceOption> options;
  final ValueChanged<String> onSelect;
}
