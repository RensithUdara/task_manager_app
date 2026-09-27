// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

const Color purpleClr = Color(0xFFA0338A);
const Color yellowClr = Color(0xFFFFB746);
const Color pinkClr = Color(0xFFF54B80);
const Color blueClr = Color(0xFF2563EB);
const Color greenClr = Color(0xFF10B981);
const Color orangeClr = Color(0xFFF97316);
const Color lightBgClr = Color(0xFFF7F8FA);
const Color darkBgClr = Color(0xFF101418);

const primaryClr = blueClr;
const Color darkGreyClr = Color(0xFF121212);
Color darkHeaderClr = const Color(0xFF1B222B);

class Themes {
  static final light = ThemeData(
    primaryColor: primaryClr,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBgClr,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBgClr,
      elevation: 0,
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryClr,
      onPrimary: Colors.white,
      secondary: Colors.black12,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.red,
      surface: Colors.white,
      onSurface: Colors.black,
      background: lightBgClr,
      onBackground: Colors.black,
    ),
  );

  static final dark = ThemeData(
    primaryColorDark: darkGreyClr,
    brightness: Brightness.dark,
    primaryColor: primaryClr,
    scaffoldBackgroundColor: darkBgClr,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBgClr,
      elevation: 0,
    ),
  );
}

TextStyle get headingTextStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Get.isDarkMode ? Colors.white : Colors.black),
  );
}

TextStyle get subHeadingTextStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: Get.isDarkMode ? Colors.grey[400] : Colors.grey),
  );
}

TextStyle get titleTextStle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Get.isDarkMode ? Colors.white : Colors.black),
  );
}

TextStyle get subTitleTextStle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 16,
        color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700]),
  );
}

TextStyle get bodyTextStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Get.isDarkMode ? Colors.white : Colors.black),
  );
}

TextStyle get body2TextStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Get.isDarkMode ? Colors.grey[200] : Colors.grey[600]),
  );
}
