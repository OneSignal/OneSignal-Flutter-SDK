import 'package:flutter/material.dart';

class AppSpacing {
  static const double gap = 8;
  static const gapBox = SizedBox(height: gap);
  static const cardPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);

  AppSpacing._();
}

class AppColors {
  static const osPrimary = Color(0xFFE54B4D);
  static const osSuccess = Color(0xFF34A853);
  static const osGrey700 = Color(0xFF616161);
  static const osGrey600 = Color(0xFF757575);
  static const osGrey500 = Color(0xFF9E9E9E);
  static const osLightBackground = Color(0xFFF8F9FA);
  static const osCardBackground = Colors.white;
  static const osCardBorder = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  static const osDivider = Color(0xFFE8EAED);
  static const osWarningBackground = Color(0xFFFFF8E1);
  static const osBackdrop = Color(0x8A000000);
  static const osLogBackground = Color(0xFF1A1B1E);
  static const osLogDebug = Color(0xFF82AAFF);
  static const osLogInfo = Color(0xFFC3E88D);
  static const osLogWarn = Color(0xFFFFCB6B);
  static const osLogError = Color(0xFFFF5370);
  static const osLogTimestamp = Color(0xFF676E7B);
  AppColors._();
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.osPrimary,
      ).copyWith(primary: AppColors.osPrimary),
      scaffoldBackgroundColor: AppColors.osLightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.osPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: AppColors.osCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.osCardBorder,
            width: 2,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          disabledForegroundColor: AppColors.osGrey500,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
      ),
      dividerColor: AppColors.osDivider,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.osGrey700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.osGrey700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.osPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.osGrey600),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  AppTheme._();
}

extension AppSnackBar on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }
}
