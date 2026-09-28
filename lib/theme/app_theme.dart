import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFFB4ACF5);

  static const lightBg = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1F2F8);
  static const lightBorder = Color(0xFFE1E3EF);

  static const lightImageWellTop = Color(0xFFFAF7F2);
  static const lightImageWellBottom = Color(0xFFF0EAE0);

  static const darkBg = Color(0xFF111418);
  static const darkSurface = Color(0xFF1B2027);
  static const darkSurfaceAlt = Color(0xFF252C35);
  static const darkBorder = Color(0xFF343D49);

  static const darkImageWellTop = Color(0xFF303843);
  static const darkImageWellBottom = Color(0xFF252C35);

  static const success = Color(0xFF17A672);
  static const successBg = Color(0xFFDEF7EC);
  static const successBgDark = Color(0xFF19392F);

  static const danger = Color(0xFFEF4444);
  static const dangerBg = Color(0xFFFDE8E8);
  static const dangerBgDark = Color(0xFF40262A);

  static const rating = Color(0xFFFFB020);
}

const appFontFamily = 'Plus Jakarta Sans';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? AppColors.primaryDark : AppColors.primary,
          onPrimary: isDark ? const Color(0xFF241E43) : Colors.white,
          onSurface: isDark ? const Color(0xFFF0F2F5) : const Color(0xFF202124),
          onSurfaceVariant: isDark
              ? const Color(0xFFABB4C1)
              : const Color(0xFF626675),
          surfaceContainerLow: isDark
              ? AppColors.darkBg
              : AppColors.lightSurface,
          surfaceContainer: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          surfaceContainerHigh: isDark
              ? AppColors.darkSurfaceAlt
              : AppColors.lightSurfaceAlt,
          outline: isDark ? const Color(0xFF737E8D) : const Color(0xFF747988),
          surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          surfaceContainerHighest: isDark
              ? AppColors.darkSurfaceAlt
              : AppColors.lightSurfaceAlt,
          outlineVariant: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        );

    final baseTextTheme = Typography.material2021(platform: TargetPlatform.iOS)
        .black
        .apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
          fontFamily: appFontFamily,
        );
    final textTheme = baseTextTheme.copyWith(
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontWeight: isDark ? FontWeight.w500 : FontWeight.w600,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontWeight: isDark ? FontWeight.w500 : FontWeight.w600,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontWeight: isDark ? FontWeight.w500 : FontWeight.w600,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      splashFactory: InkRipple.splashFactory,
      fontFamily: appFontFamily,
      textTheme: textTheme,
      dividerColor: scheme.outlineVariant,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black.withValues(alpha: 0.6),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.12),
        circularTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
          fontFamily: appFontFamily,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
          fontFamily: appFontFamily,
        ),
        secondaryLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onPrimary,
          fontFamily: appFontFamily,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

extension AppColorScheme on ColorScheme {
  Color get successForeground => brightness == Brightness.dark
      ? const Color(0xFF80D5B2)
      : AppColors.success;
  Color get dangerForeground => brightness == Brightness.dark
      ? const Color(0xFFF3A1A8)
      : AppColors.danger;
  Color get toolbarBackground =>
      brightness == Brightness.dark ? surface : primary;
  Color get toolbarForeground =>
      brightness == Brightness.dark ? onSurface : onPrimary;

  Color get cardBorder => brightness == Brightness.dark
      ? AppColors.darkBorder
      : AppColors.lightBorder;

  Color get imageWell => brightness == Brightness.dark
      ? AppColors.darkSurfaceAlt
      : AppColors.lightSurfaceAlt;

  Gradient get imageWellGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: brightness == Brightness.dark
        ? [AppColors.darkImageWellTop, AppColors.darkImageWellBottom]
        : [AppColors.lightImageWellTop, AppColors.lightImageWellBottom],
  );

  Color get successBg => brightness == Brightness.dark
      ? AppColors.successBgDark
      : AppColors.successBg;

  Color get dangerBg => brightness == Brightness.dark
      ? AppColors.dangerBgDark
      : AppColors.dangerBg;

  Color get cardShadow => brightness == Brightness.dark
      ? Colors.black.withValues(alpha: 0.18)
      : const Color(0xFF2B2D5C).withValues(alpha: 0.13);
}
