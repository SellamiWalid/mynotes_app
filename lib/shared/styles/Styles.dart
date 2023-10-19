import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:notes/shared/styles/Colors.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Varela',
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: lightPrimaryColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 19.0,
      letterSpacing: 0.6,
      color: Colors.black,
      fontFamily: 'Varela',
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: lightPrimaryColor,
  )
);


// 191C1E



ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Varela',
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: HexColor('101010'),
  colorScheme: ColorScheme.dark(
    primary: darkPrimaryColor,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: HexColor('101010'),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    elevation: 0,
    titleTextStyle: const TextStyle(
      fontSize: 19.0,
      letterSpacing: 0.6,
      color: Colors.white,
      fontFamily: 'Varela',
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: HexColor('101010'),
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: HexColor('101010'),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkFloatColor,
  ),
);
