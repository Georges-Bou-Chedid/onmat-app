import 'dart:ui';

class Belt {
  final Color color;
  final Color? stripeColor;
  final int classesPerStripe;
  final String ageRange;

  Belt({
    required this.color,
    this.stripeColor,
    required this.classesPerStripe,
    required this.ageRange,
  });
}
