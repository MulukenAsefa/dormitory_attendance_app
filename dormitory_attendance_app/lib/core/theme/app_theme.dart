import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryDarkColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  
  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimaryColor = Colors.white;
  static const Color darkTextSecondaryColor = Color(0xFFB3B3B3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: textPrimaryColor,
        onSurface: textPrimaryColor,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        titleSmall: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: textPrimaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: textSecondaryColor,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          side: const BorderSide(color: primaryColor),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        background: darkBackgroundColor,
        surface: darkSurfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: darkTextPrimaryColor,
        onSurface: darkTextPrimaryColor,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: darkTextPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: darkTextPrimaryColor,
        ),
        titleSmall: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: darkTextPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: darkTextPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: darkTextPrimaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: darkTextSecondaryColor,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}