import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromRGBO(178, 5, 31, 1),
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(255, 250, 240, 1.0),
  appBarTheme: AppBarTheme(
    elevation: 0,
    color: const Color.fromRGBO(255, 250, 240, 1.0),
    titleTextStyle: GoogleFonts.euphoriaScript(
      fontSize: 35.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    titleLarge: GoogleFonts.euphoriaScript(
      fontSize: 40.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromRGBO(5, 178, 74, 1),
    surface: Color.fromRGBO(
        45, 45, 45, 1), // This would be your primary dark background color
    background: Color.fromRGBO(
        35, 35, 35, 1), // A slightly darker background for contrast
    onPrimary: Colors.white, // Text color on primary color
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(45, 45, 45, 1.0),
  appBarTheme: AppBarTheme(
    elevation: 0,
    color: const Color.fromRGBO(35, 35, 35, 1.0),
    titleTextStyle: GoogleFonts.euphoriaScript(
      fontSize: 35.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    titleLarge: GoogleFonts.euphoriaScript(
      fontSize: 40.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white, // Icon color in dark mode
  ),
);
