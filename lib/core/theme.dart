import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgColor = Color(0xFFF8F8FA);
  static const Color primaryRose = Color(0xFFB9937E);
  static const Color primaryBeige = Color(0xFFE5D1C5);
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textLight = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRose,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRose,
        primary: primaryRose,
        onPrimary: Colors.white,
        secondary: primaryBeige,
        surface: surfaceWhite,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 28.sp,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 22.sp,
        ),
        bodyLarge: GoogleFonts.outfit(color: textDark, fontSize: 15.sp),
        bodyMedium: GoogleFonts.outfit(color: textLight, fontSize: 13.sp),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRose,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 32.w),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: primaryRose, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryRose,
      scaffoldBackgroundColor: const Color(0xFF0F0F12),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRose,
        primary: primaryRose,
        onPrimary: Colors.white,
        secondary: primaryBeige,
        surface: const Color(0xFF19191E),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: const Color(0xFFF3F3F7),
          fontWeight: FontWeight.bold,
          fontSize: 28.sp,
        ),
        displayMedium: GoogleFonts.outfit(
          color: const Color(0xFFF3F3F7),
          fontWeight: FontWeight.bold,
          fontSize: 22.sp,
        ),
        bodyLarge: GoogleFonts.outfit(color: const Color(0xFFF3F3F7), fontSize: 15.sp),
        bodyMedium: GoogleFonts.outfit(color: const Color(0xFFA0A0AB), fontSize: 13.sp),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRose,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 32.w),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF19191E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: primaryRose, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF19191E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
    );
  }
}

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme() {
    themeModeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }
}

extension ThemeHelper on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get surfaceColor => isDarkMode ? const Color(0xFF19191E) : Colors.white;
  Color get scaffoldBg => isDarkMode ? const Color(0xFF0F0F12) : const Color(0xFFF3F3F7);
  Color get textColor => isDarkMode ? const Color(0xFFF3F3F7) : const Color(0xFF2D2D2D);
  Color get subtextColor => isDarkMode ? const Color(0xFFA0A0AB) : Colors.grey.shade600;
  Color get cardColor => isDarkMode ? const Color(0xFF1E1E24) : Colors.white;
  Color get borderColor => isDarkMode ? const Color(0xFF2A2A32) : Colors.grey.shade100;
}

