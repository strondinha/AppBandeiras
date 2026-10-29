import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF10191E);
  static const surface = Color(0xFF19252C);
  static const raised = Color(0xFF22323A);
  static const line = Color(0xFF31424A);
  static const text = Color(0xFFF3F5ED);
  static const muted = Color(0xFFABBABF);
  static const lime = Color(0xFFC5F779);
  static const gold = Color(0xFFFFCA7A);
  static const blue = Color(0xFF96C9F4);
  static const error = Color(0xFFFFA4A0);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.lime,
    brightness: Brightness.dark,
    surface: AppColors.surface,
    primary: AppColors.lime,
    onPrimary: AppColors.background,
    error: AppColors.error,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Manrope',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        height: 1.12,
        letterSpacing: -1.6,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 16, height: 1.55),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 50),
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lime),
      ),
      labelStyle: const TextStyle(color: AppColors.muted),
      counterStyle: const TextStyle(color: AppColors.muted),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.lime,
      backgroundColor: AppColors.background,
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
