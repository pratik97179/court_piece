import 'package:flutter/widgets.dart';

class Motion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 340);
  static const Duration slow = Duration(milliseconds: 560);

  static const Curve curve = Cubic(0.22, 1, 0.36, 1);

  static const SpringDescription spring = SpringDescription(
    mass: 0.85,
    stiffness: 190,
    damping: 18,
  );

  static Duration of(BuildContext context, Duration wanted) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Duration.zero;
    }
    return wanted;
  }
}
