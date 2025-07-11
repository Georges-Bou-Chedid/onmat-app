import 'package:flutter/material.dart';

ThemeData darkTheme() {
  return ThemeData(
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFDF1E42),
    // Primary theme color
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(width: 1.0, color: Colors.white), // Default border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(width: 1.0, color: Colors.white), // Focused border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(width: 1.0, color: Colors.white.withOpacity(0.5)), // Non-focused color
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.white,
        ),
        labelStyle: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold
        )
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white.withOpacity(0.8), // Set cursor color globally here
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFFDF1E42)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        )),
        minimumSize: WidgetStateProperty.all(const Size(100, 42)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(width: 1.0, color: Colors.white),
      // Set the border width and color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      // Optional: adjust shape
      checkColor: MaterialStateProperty.all<Color>(Color(0xFF1E1E1E)), // Optional: set check color
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFDF1E42),
      secondary: Colors.white,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      strokeWidth: 2,
      color: Color(0xFF1E1E1E), // Your desired color
      circularTrackColor: Colors.white, // Optional: Track color
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.5), // Muted yellow-green border
          width: 2,
        ),
      ),
      elevation: 4,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white, // Set divider color
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: Color(0xFF1E1E1E).withOpacity(0.5),
            width: 2
        ),
      ),
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.white54,
      ),
    ),
  );
}


ThemeData lightTheme() {
  return ThemeData(
    fontFamily: 'Inter',
    brightness: Brightness.light,
    primaryColor: const Color(0xFFDF1E42),
    // Primary theme color
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E1E),
      ),
      iconTheme: IconThemeData(color: Color(0xFF1E1E1E)),
    ),
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(
              width: 1.0, color: Color(0xFF1E1E1E)), // Default border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(
              width: 1.0, color: Color(0xFF1E1E1E)), // Focused border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(width: 1.0,
              color: Color(0xFF1E1E1E).withOpacity(0.5)), // Non-focused color
        ),
        floatingLabelStyle: TextStyle(
          color: Color(0xFF1E1E1E),
        ),
        labelStyle: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 14.0,
            fontWeight: FontWeight.bold)
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color(0xFF1E1E1E).withOpacity(0.8), // Set cursor color globally here
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFFDF1E42)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        )),
        minimumSize: WidgetStateProperty.all(const Size(100, 42)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Color(0xFF1E1E1E)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Color(0xFF1E1E1E)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(width: 1.0, color: Color(0xFF1E1E1E)),
      // Set the border width and color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      // Optional: adjust shape
      checkColor: MaterialStateProperty.all<Color>(
          Color(0xFF1E1E1E)), // Optional: set check color
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1E1E1E)),
      bodyMedium: TextStyle(color: Color(0xFF1E1E1E)),
      bodySmall: TextStyle(color: Color(0xFF1E1E1E)),
      headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
      labelLarge: TextStyle(color: Color(0xFF1E1E1E)),
      labelMedium: TextStyle(color: Color(0xFF1E1E1E)),
      titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E1E1E)),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFDF1E42),
      secondary: Colors.white,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      strokeWidth: 2,
      color: Color(0xFF1E1E1E), // Your desired color
      circularTrackColor: Colors.white, // Optional: Track color
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Color(0xFF1E1E1E).withOpacity(0.5),
          // Same border color for consistency
          width: 2,
        ),
      ),
      elevation: 4,
    ),
    dividerTheme: DividerThemeData(
      color: Color(0xFF1E1E1E), // Set divider color
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: Color(0xFF1E1E1E).withOpacity(0.5),
            width: 2
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E1E),
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
    ),
  );
}