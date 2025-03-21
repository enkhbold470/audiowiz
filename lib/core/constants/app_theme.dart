import 'package:flutter/material.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      error: AppConstants.errorColor,
      background: AppConstants.backgroundColor,
    ),
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding, 
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppConstants.defaultBorderRadius,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.defaultBorderRadius,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppConstants.accentColor,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      error: AppConstants.errorColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding, 
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppConstants.defaultBorderRadius,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.defaultBorderRadius,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppConstants.accentColor,
      foregroundColor: Colors.white,
    ),
  );
} 