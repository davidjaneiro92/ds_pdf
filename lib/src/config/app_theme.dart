import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_colors.dart';

/// `ThemeData` claro/escuro do replanejamento visual (ver
/// [custom_colors.dart]). Tipografia: títulos em Barlow Condensed (peso
/// 600, condensada — dá o caráter "blueprint" do documento), corpo em
/// Barlow. Cantos com raio pequeno (`CustomColors.radiusMd/Lg`), sem
/// elevação alta — o documento pede hierarquia por espaço/tipografia, não
/// por sombra.
abstract class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: CustomColors.bgLight,
        surface: CustomColors.surfaceLight,
        text: CustomColors.textLight,
        divider: CustomColors.dividerLight,
        accent: CustomColors.accentLight,
        accentStrong: CustomColors.accentLightStrong,
        onAccent: CustomColors.bgLight,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: CustomColors.bgDark,
        surface: CustomColors.surfaceDark,
        text: CustomColors.textDark,
        divider: CustomColors.dividerDark,
        accent: CustomColors.accentDark,
        accentStrong: CustomColors.accentDarkStrong,
        onAccent: CustomColors.bgDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color divider,
    required Color accent,
    required Color accentStrong,
    required Color onAccent,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      secondary: accentStrong,
      onSecondary: onAccent,
      surface: surface,
      onSurface: text,
      error: const Color(0xFFC94A3B),
      onError: Colors.white,
      outline: divider,
    );

    final headingFamily = GoogleFonts.barlowCondensedTextTheme();
    final bodyFamily = GoogleFonts.barlowTextTheme();

    final textTheme = bodyFamily
        .apply(bodyColor: text, displayColor: text)
        .copyWith(
          headlineLarge: headingFamily.headlineLarge
              ?.copyWith(color: text, fontWeight: FontWeight.w600),
          headlineMedium: headingFamily.headlineMedium
              ?.copyWith(color: text, fontWeight: FontWeight.w600),
          headlineSmall: headingFamily.headlineSmall
              ?.copyWith(color: text, fontWeight: FontWeight.w600),
          titleLarge: headingFamily.titleLarge
              ?.copyWith(color: text, fontWeight: FontWeight.w600),
          titleMedium: headingFamily.titleMedium
              ?.copyWith(color: text, fontWeight: FontWeight.w600),
          titleSmall: headingFamily.titleSmall
              ?.copyWith(color: text, fontWeight: FontWeight.w600),
        );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      dividerColor: divider,
      useMaterial3: true,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: headingFamily.titleLarge?.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomColors.radiusLg),
          side: BorderSide(color: divider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size.fromHeight(52),
          textStyle:
              headingFamily.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomColors.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: divider),
          minimumSize: const Size.fromHeight(52),
          textStyle:
              headingFamily.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomColors.radiusMd),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomColors.radiusLg),
        ),
        titleTextStyle: headingFamily.titleLarge
            ?.copyWith(color: text, fontWeight: FontWeight.w600),
        contentTextStyle: bodyFamily.bodyMedium?.copyWith(color: text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CustomColors.radiusMd),
          borderSide: BorderSide(color: divider),
        ),
      ),
    );
  }
}
