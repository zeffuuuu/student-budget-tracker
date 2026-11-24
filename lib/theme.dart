import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colour palette inspired by the Touch 'n Go eWallet look:
/// strong blue as the main colour, bright yellow as the accent.
class AppColors {
  static const primary = Color(0xFF005ABB);
  static const primaryDark = Color(0xFF00408A);
  static const primaryLight = Color(0xFF3B8CF0);
  static const primarySoft = Color(0xFFDCEAFF);
  static const secondary = Color(0xFFFFC72C);
  static const warning = Color(0xFFF59E0B);
  static const background = Color(0xFFF1F5FB);
  static const expense = Color(0xFFE5484D);
  static const income = Color(0xFF18A874);
  static const textDark = Color(0xFF14213D);
  static const textMuted = Color(0xFF6B7A90);
}

/// ThemeData defined ONCE and applied in MaterialApp.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.primaryDark,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: AppColors.primarySoft,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
        fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
    titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
    bodyMedium: TextStyle(fontSize: 15, color: AppColors.textMuted),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);
