import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/shared/styles/Colors.dart';

ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Varela',
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: lightBgColor,
    colorScheme: ColorScheme.light(
      primary: lightPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBgColor,
      scrolledUnderElevation: 0.0,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 18.0,
        letterSpacing: 0.6,
        color: Colors.black,
        fontFamily: 'Varela',
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: lightBgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: lightBgColor,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: lightBgColor,
      showDragHandle: true,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: lightBgColor,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightPrimaryColor,
    ));



ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Varela',
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: darkBgColor,
  colorScheme: ColorScheme.dark(
    primary: darkPrimaryColor,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkBgColor,
    scrolledUnderElevation: 0.0,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    elevation: 0,
    titleTextStyle: const TextStyle(
      fontSize: 18.0,
      letterSpacing: 0.6,
      color: Colors.white,
      fontFamily: 'Varela',
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: darkBgColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: darkBgColor,
      statusBarBrightness: Brightness.light,
    ),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: darkBgColor,
    showDragHandle: true,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.blueGrey.shade900,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkPrimaryColor,
  ),
);
