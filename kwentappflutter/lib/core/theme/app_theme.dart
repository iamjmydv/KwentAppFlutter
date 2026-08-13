import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF4F46E5);
  static const onPrimary = Color(0xFFFFFFFF);
  static const background = Color(0xFFFAFAF9);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111827);
  static const inkSub = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const field = Color(0xFFF3F4F6);
  static const danger = Color(0xFFDC2626);
  static const dangerText = Color(0xFFB91C1C);
  static const onDanger = Color(0xFFFFFFFF);

  static const darkPrimary = Color(0xFF818CF8);
  static const darkOnPrimary = Color(0xFF1E1B4B);
  static const darkBackground = Color(0xFF0C0A1D);
  static const darkSurface = Color(0xFF161331);
  static const darkInk = Color(0xFFE5E7EB);
  static const darkInkSub = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF2E2A4F);
  static const darkField = Color(0xFF1D1940);
  static const darkDanger = Color(0xFFF87171);
  static const darkDangerText = Color(0xFFF87171);
  static const darkOnDanger = Color(0xFF2B0708);
}

class AppRadius {
  const AppRadius._();

  static const field = 12.0;
  static const card = 16.0;
}

class AppLayout {
  const AppLayout._();

  static const contentMaxWidth = 430.0;
}

class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

class AppTheme {
  const AppTheme._();

  static const fontFamily = 'Poppins';

  static ThemeData light() => _build(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        background: AppColors.background,
        surface: AppColors.surface,
        ink: AppColors.ink,
        inkSub: AppColors.inkSub,
        border: AppColors.border,
        field: AppColors.field,
        danger: AppColors.danger,
        dangerText: AppColors.dangerText,
        onDanger: AppColors.onDanger,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        ink: AppColors.darkInk,
        inkSub: AppColors.darkInkSub,
        border: AppColors.darkBorder,
        field: AppColors.darkField,
        danger: AppColors.darkDanger,
        dangerText: AppColors.darkDangerText,
        onDanger: AppColors.darkOnDanger,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color background,
    required Color surface,
    required Color ink,
    required Color inkSub,
    required Color border,
    required Color field,
    required Color danger,
    required Color dangerText,
    required Color onDanger,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      surface: surface,
      onSurface: ink,
      error: danger,
      onError: onDanger,
      outline: border,
      surfaceContainerHighest: field,
      onSurfaceVariant: inkSub,
    );

    final textTheme = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 22 / 14,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: inkSub,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        shape: Border(bottom: BorderSide(color: border)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: inkSub,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: danger, width: 1.5),
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          color: dangerText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: surface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? primary : inkSub,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w500
                : FontWeight.w400,
            color: states.contains(WidgetState.selected) ? primary : inkSub,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: const CircleBorder(),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: brightness == Brightness.light
              ? AppColors.surface
              : AppColors.darkBackground,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
    );
  }
}
