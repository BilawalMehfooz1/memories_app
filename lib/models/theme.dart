import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromRGBO(178, 5, 31, 1),
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(255, 250, 240, 1.0),
  // appBarTheme: AppBarTheme(
  //   elevation: 0,
  //   color: const Color.fromRGBO(255, 250, 240, 1.0),
  //   titleTextStyle: GoogleFonts.euphoriaScript(
  //     fontSize: 30.0,
  //     color: Colors.black,
  //     fontWeight: FontWeight.bold,
  //   ),
  // ),
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    titleLarge: GoogleFonts.euphoriaScript(
      fontSize: 40.0, 
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
);
