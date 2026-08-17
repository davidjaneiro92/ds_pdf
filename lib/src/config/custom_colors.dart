import 'package:flutter/material.dart';

/// Paleta do replanejamento visual do app (ver
/// `especificacao/replanejamento/` — documento de referência convertido a
/// partir do zip enviado pelo usuário em 2026-08-16). Substitui o ciano da
/// logo usado antes: o usuário decidiu, ao ver a crítica de contraste do
/// documento, adotar o azul-acinzentado das telas propostas em vez de
/// manter o ciano.
abstract class CustomColors {
  // ── Tema claro ────────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF2F2F3);
  static const Color surfaceLight = Color(0xFFE9E9EA);
  static const Color textLight = Color(0xFF1D1F20);
  static const Color dividerLight = Color(0x291D1F20); // #1D1F20 a 16%
  static const Color accentLight = Color(0xFF5980A6);
  static const Color accentLightStrong = Color(0xFF416180); // accent-700
  static const Color tagBgLight = Color(0xFFEEF6FF); // accent-100
  static const Color tagTextLight = Color(0xFF2C455D); // accent-800

  // ── Tema escuro ───────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF16191C);
  static const Color surfaceDark = Color(0xFF1E2228);
  static const Color textDark = Color(0xFFE8EAEC);
  static const Color dividerDark = Color(0x33E8EAEC); // #E8EAEC a 20%
  static const Color accentDark = Color(0xFF94BCE3);
  static const Color accentDarkStrong = Color(0xFFB5D9FD);
  static const Color tagBgDark = Color(0xFF2C455D); // accent-800
  static const Color tagTextDark = Color(0xFFD6EBFF); // accent-200

  // ── Neutros (independentes de tema: placeholders de imagem, hairlines) ─
  static const Color neutral100 = Color(0xFFF5F5F8);
  static const Color neutral200 = Color(0xFFE7E7EA);
  static const Color neutral300 = Color(0xFFD4D4D7);
  static const Color neutral400 = Color(0xFFB7B7BA);
  static const Color neutral700 = Color(0xFF5D5D60);
  static const Color neutral800 = Color(0xFF424244);
  static const Color neutral900 = Color(0xFF2B2B2D);

  /// Raio de borda do sistema de design (`--radius-sm/md/lg` do documento).
  static const double radiusSm = 2;
  static const double radiusMd = 4;
  static const double radiusLg = 7;
}
