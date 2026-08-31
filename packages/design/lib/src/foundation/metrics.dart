import 'package:flutter/widgets.dart';

enum Breakpoint { compact, medium, expanded }

Breakpoint breakpointFor(Size size) {
  final w = size.width;
  if (w < 600) {
    return Breakpoint.compact;
  }
  if (w < 1024) {
    return Breakpoint.medium;
  }
  return Breakpoint.expanded;
}

class Space {
  const Space(this.unit);

  factory Space.of(Size size) {
    final unit = (size.shortestSide / 80).clamp(4.0, 12.0);
    return Space(unit);
  }

  final double unit;

  double get xs => unit * 0.5;
  double get sm => unit;
  double get md => unit * 2;
  double get lg => unit * 3;
  double get xl => unit * 5;
  double get hair => unit * 0.15;
  double get radius => unit * 0.9;
  double get cardRadius => unit * 0.45;
}

class TypeScale {
  const TypeScale(this.space);

  final Space space;

  TextStyle get display => TextStyle(
    fontSize: space.unit * 4.2,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.8,
  );

  TextStyle get title => TextStyle(
    fontSize: space.unit * 2.1,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  TextStyle get body => TextStyle(
    fontSize: space.unit * 1.7,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  TextStyle get label => TextStyle(
    fontSize: space.unit * 1.35,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.4,
  );
}
