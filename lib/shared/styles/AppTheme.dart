import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/shared/styles/AppColors.dart';

class AppTheme {

  AppTheme._();

  static ThemeData lightTheme () => ThemeData(
      useMaterial3: true,
      fontFamily: 'Outfit',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: AppColors.lightBgColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBgColor,
        scrolledUnderElevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 18.0,
          letterSpacing: 0.6,
          color: Colors.black,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: AppColors.lightBgColor,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.lightBgColor,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightBgColor,
        showDragHandle: true,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightBgColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimaryColor,
      ));

  static ThemeData darkTheme () => ThemeData(
    useMaterial3: true,
    fontFamily: 'Outfit',
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: AppColors.darkBgColor,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBgColor,
      scrolledUnderElevation: 0.0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 18.0,
        letterSpacing: 0.6,
        color: Colors.white,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: AppColors.darkBgColor,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkBgColor,
        statusBarBrightness: Brightness.light,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.darkBgColor,
      showDragHandle: true,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.blueGrey.shade900,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkPrimaryColor,
    ),
  );

}