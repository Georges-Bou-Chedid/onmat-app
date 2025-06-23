import 'package:flutter/material.dart';

ThemeData darkTheme() =>
    ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF8BC34A), // Primary theme color
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: "Inter",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFECEFF1),
        ),
        iconTheme: IconThemeData(color: Color(0xFFECEFF1)),
      ),
      inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(width: 1.0, color: Color(0xFFECEFF1)), // Default border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(width: 1.0, color: Color(0xFFECEFF1)), // Focused border color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(width: 1.0, color: Color(0xFFECEFF1).withOpacity(0.5)), // Non-focused color
          ),
          floatingLabelStyle: TextStyle(
            color: Color(0xFFECEFF1),
          ),
          labelStyle: TextStyle(fontFamily: "Inter", color: Color(0xFFECEFF1), fontSize: 14.0, fontWeight: FontWeight.bold)
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFFECEFF1).withOpacity(0.8), // Set cursor color globally here
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF8BC34A)),
          foregroundColor: WidgetStateProperty.all(const Color(0xFF1E1E1E)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          )),
          minimumSize: WidgetStateProperty.all(const Size(100, 42)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Color(0xFFECEFF1).withOpacity(0.8)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(width: 1.0, color: Color(0xFFECEFF1)), // Set the border width and color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)), // Optional: adjust shape
        checkColor: MaterialStateProperty.all<Color>(Color(0xFF1E1E1E)), // Optional: set check color
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: "Inter", color: Color(0xFFECEFF1)),
        bodyMedium: TextStyle(fontFamily: "Inter", color: Color(0xFFECEFF1)),
        bodySmall: TextStyle(fontFamily: "Inter", color: Color(0xFFECEFF1)),
        headlineLarge: TextStyle(fontFamily: "Inter", fontWeight: FontWeight.bold, color: Color(0xFFECEFF1)),
        headlineMedium: TextStyle(fontFamily: "Inter", fontWeight: FontWeight.bold, color: Color(0xFFECEFF1)),
        labelLarge: TextStyle(fontFamily: "Inter", color: Color(0xFFECEFF1)),
        labelMedium: TextStyle(fontFamily: "Inter", color: Color(0xFFECEFF1)),
        titleMedium: TextStyle(fontFamily: "Inter", fontWeight: FontWeight.w500, color: Color(0xFFECEFF1)),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8BC34A),
        secondary: Color(0xFFECEFF1),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF8BC34A), // Your desired color
        circularTrackColor: Color(0xFFECEFF1), // Optional: Track color
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color(0xFFECEFF1).withOpacity(0.5), // Muted yellow-green border
            width: 2,
          ),
        ),
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: Color(0xFFECEFF1), // Set divider color
      ),
    );


ThemeData lightTheme() =>
    ThemeData.light().copyWith(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF8BC34A), // Primary theme color
      scaffoldBackgroundColor: Color(0xFFECEFF1),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: "Inter",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E1E1E),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1E1E1E)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(width: 1.0, color: Color(0xFF1E1E1E)), // Default border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(width: 1.0, color: Color(0xFF1E1E1E)), // Focused border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(width: 1.0, color: Color(0xFF1E1E1E).withOpacity(0.5)), // Non-focused color
        ),
        floatingLabelStyle: TextStyle(
          color: Color(0xFF1E1E1E),
        ),
        labelStyle: TextStyle(fontFamily: "Inter", color: Color(0xFF1E1E1E), fontSize: 14.0, fontWeight: FontWeight.bold)
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF1E1E1E).withOpacity(0.8), // Set cursor color globally here
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF8BC34A)),
          foregroundColor: WidgetStateProperty.all(const Color(0xFF1E1E1E)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          )),
          minimumSize: WidgetStateProperty.all(const Size(100, 42)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Color(0xFF1E1E1E).withOpacity(0.8)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(width: 1.0, color: Color(0xFF1E1E1E)), // Set the border width and color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)), // Optional: adjust shape
        checkColor: MaterialStateProperty.all<Color>(Color(0xFF1E1E1E)), // Optional: set check color
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: "Inter", color: Color(0xFF1E1E1E)),
        bodyMedium: TextStyle(fontFamily: "Inter", color: Color(0xFF1E1E1E)),
        bodySmall: TextStyle(fontFamily: "Inter", color: Color(0xFF1E1E1E)),
        headlineLarge: TextStyle(fontFamily: "Inter", fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        headlineMedium: TextStyle(fontFamily: "Inter", fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        labelLarge: TextStyle(fontFamily: "Inter", color: Color(0xFF1E1E1E)),
        labelMedium: TextStyle(fontFamily: "Inter", color: Color(0xFF1E1E1E)),
        titleMedium: TextStyle(fontFamily: "Inter", fontWeight: FontWeight.w500, color: Color(0xFF1E1E1E)),
      ),
      cardTheme: CardTheme(
        color: Color(0xFFECEFF1),
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8BC34A),
        secondary: Color(0xFFECEFF1),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF8BC34A), // Your desired color
        circularTrackColor: Color(0xFFECEFF1), // Optional: Track color
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Color(0xFFECEFF1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color(0xFF1E1E1E).withOpacity(0.5), // Same border color for consistency
            width: 2,
          ),
        ),
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: Color(0xFF1E1E1E), // Set divider color
      ),
    );