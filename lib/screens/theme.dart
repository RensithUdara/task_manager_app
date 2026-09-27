import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const Color purpleClr = Color(0xFF7C3AED);
const Color yellowClr = Color(0xFFF5B942);
const Color pinkClr = Color(0xFFE85D75);
const Color blueClr = Color(0xFF356AE6);
const Color greenClr = Color(0xFF16A07A);
const Color orangeClr = Color(0xFFEE7B45);
const Color lightBgClr = Color(0xFFF4F6F9);
const Color darkBgClr = Color(0xFF111418);
const Color inkClr = Color(0xFF1D2433);
const Color lightBorderClr = Color(0xFFE2E6EC);

const primaryClr = blueClr;
const Color darkGreyClr = Color(0xFF121212);
const Color darkHeaderClr = Color(0xFF1B2028);

class Themes {
  static final light = _buildTheme(Brightness.light);
  static final dark = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryClr,
      brightness: brightness,
    ).copyWith(
      surface: isDark ? darkHeaderClr : Colors.white,
      onSurface: isDark ? const Color(0xFFF4F6FA) : inkClr,
      error: const Color(0xFFDC4C5A),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: primaryClr,
      scaffoldBackgroundColor: isDark ? darkBgClr : lightBgClr,
      textTheme: GoogleFonts.latoTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkBgClr : lightBgClr,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: isDark ? Colors.white12 : lightBorderClr,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? Colors.white12 : lightBorderClr,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF89909D),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _inputBorder(isDark),
        enabledBorder: _inputBorder(isDark),
        focusedBorder: _inputBorder(isDark, focused: true),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryClr,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryClr,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(bool isDark, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: focused
            ? primaryClr
            : isDark
                ? Colors.white12
                : lightBorderClr,
        width: focused ? 1.5 : 1,
      ),
    );
  }
}

TextStyle get headingTextStyle => GoogleFonts.lato(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: Get.isDarkMode ? Colors.white : inkClr,
    );

TextStyle get subHeadingTextStyle => GoogleFonts.lato(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Get.isDarkMode ? Colors.grey[300] : const Color(0xFF5D6573),
    );

TextStyle get titleTextStle => GoogleFonts.lato(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Get.isDarkMode ? Colors.white : inkClr,
    );

TextStyle get subTitleTextStle => GoogleFonts.lato(
      fontSize: 15,
      color: Get.isDarkMode ? Colors.grey[400] : const Color(0xFF697180),
    );

TextStyle get bodyTextStyle => GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Get.isDarkMode ? Colors.white : inkClr,
    );

TextStyle get body2TextStyle => GoogleFonts.lato(
      fontSize: 14,
      color: Get.isDarkMode ? Colors.grey[400] : const Color(0xFF697180),
    );
