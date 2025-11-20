import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vousvous/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.nunitoSansTextTheme(),
    useMaterial3: true,
  );
}
