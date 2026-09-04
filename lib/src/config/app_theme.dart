import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_colors.dart';

/// `ThemeData` claro/escuro do replanejamento visual (ver
/// [custom_colors.dart]). Tipografia: títulos em Barlow Condensed (peso
/// 600, condensada — dá o caráter "blueprint" do documento), corpo em
/// Barlow. Cantos retos (`BorderRadius.zero`) em tudo, sem elevação alta —
/// o documento pede hierarquia por espaço/tipografia e borda de 1px, não
/// por raio ou sombra.
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
          borderRadius: CustomColors.radiusZero,
          side: BorderSide(color: divider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          // `Size.fromHeight(52)` equivale a `Size(double.infinity, 52)` —
          // força largura mínima infinita, o que quebra (BoxConstraints
          // forces an infinite width) qualquer botão colocado direto numa
          // Row sem Expanded/SizedBox de largura fixa (ex.: o rodapé de
          // Texto→PDF). Botões que devem ocupar a largura toda continuam
          // fazendo isso normalmente quando envolvidos em
          // `SizedBox(width: double.infinity, child: ...)`, já que aí quem
          // manda na largura é o SizedBox, não este mínimo.
          minimumSize: const Size(88, 52),
          textStyle:
              headingFamily.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: CustomColors.radiusZero,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: divider),
          // `Size.fromHeight(52)` equivale a `Size(double.infinity, 52)` —
          // força largura mínima infinita, o que quebra (BoxConstraints
          // forces an infinite width) qualquer botão colocado direto numa
          // Row sem Expanded/SizedBox de largura fixa (ex.: o rodapé de
          // Texto→PDF). Botões que devem ocupar a largura toda continuam
          // fazendo isso normalmente quando envolvidos em
          // `SizedBox(width: double.infinity, child: ...)`, já que aí quem
          // manda na largura é o SizedBox, não este mínimo.
          minimumSize: const Size(88, 52),
          textStyle:
              headingFamily.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: CustomColors.radiusZero,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: CustomColors.radiusZero,
        ),
        titleTextStyle: headingFamily.titleLarge
            ?.copyWith(color: text, fontWeight: FontWeight.w600),
        contentTextStyle: bodyFamily.bodyMedium?.copyWith(color: text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: CustomColors.radiusZero,
          borderSide: BorderSide(color: divider),
        ),
      ),
    );
  }
}
