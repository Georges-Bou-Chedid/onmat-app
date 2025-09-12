import 'package:flutter/material.dart';

class Belt {
  final String id;
  final int minAge;
  final int maxAge;
  final Color beltColor1;
  final Color? beltColor2;
  final int classesPerBeltOrStripe;
  late int priority;

  Belt({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.beltColor1,
    this.beltColor2,
    required this.classesPerBeltOrStripe,
    required this.priority
  });

  // Deep copy method
  Belt copy() {
    return Belt(
      id: id,
      minAge: minAge,
      maxAge: maxAge,
      beltColor1: beltColor1,
      beltColor2: beltColor2,
      classesPerBeltOrStripe: classesPerBeltOrStripe,
      priority: priority,
    );
  }

  // --- Conversion helpers ---
  static Map<Color, String> colorToName = {
    Colors.white: "white",
    Colors.black: "black",
    Colors.grey: "grey",
    Colors.yellow: "yellow",
    Colors.orange: "orange",
    Colors.green: "green",
    Colors.blue: "blue",
    Colors.purple: "purple",
    Colors.brown: "brown",
  };

  static const Map<String, Color> nameToColor = {
    "white": Colors.white,
    "grey": Colors.grey,
    "yellow": Colors.yellow,
    "orange": Colors.orange,
    "green": Colors.green,
    "blue": Colors.blue,
    "purple": Colors.purple,
    "brown": Colors.brown,
    "black": Colors.black,
  };

  static String getColorName(Color color) {
    return colorToName[color] ?? "unknown";
  }

  static Color getColorFromName(String name) {
    return nameToColor[name] ?? Colors.transparent;
  }
}
