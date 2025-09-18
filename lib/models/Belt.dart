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
    Colors.white: "White",
    Colors.black: "Black",
    Colors.grey: "Grey",
    Colors.yellow: "Yellow",
    Colors.orange: "Orange",
    Colors.green: "Green",
    Colors.blue: "Blue",
    Colors.purple: "Purple",
    Colors.brown: "Brown",
  };

  static const Map<String, Color> nameToColor = {
    "White": Colors.white,
    "Grey": Colors.grey,
    "Yellow": Colors.yellow,
    "Orange": Colors.orange,
    "Green": Colors.green,
    "Blue": Colors.blue,
    "Purple": Colors.purple,
    "Brown": Colors.brown,
    "Black": Colors.black,
  };

  static String getColorName(Color color) {
    return colorToName[color] ?? "unknown";
  }

  static Color getColorFromName(String name) {
    return nameToColor[name] ?? Colors.transparent;
  }
}
