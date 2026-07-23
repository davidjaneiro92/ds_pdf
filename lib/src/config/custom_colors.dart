import 'package:flutter/material.dart';

// Ciano da logo/ícone do app (assets/icon/icon.png), extraído por
// amostragem de pixel (média de pontos no traço brilhante do ícone:
// ~R1 G222 B234).
const int _brandValue = 0xFF01DEEA;

Map<int, Color> _opacidade = {
  50: const Color.fromRGBO(1, 222, 234, .1),
  100: const Color.fromRGBO(1, 222, 234, .2),
  200: const Color.fromRGBO(1, 222, 234, .3),
  300: const Color.fromRGBO(1, 222, 234, .4),
  400: const Color.fromRGBO(1, 222, 234, .5),
  500: const Color.fromRGBO(1, 222, 234, .6),
  600: const Color.fromRGBO(1, 222, 234, .7),
  700: const Color.fromRGBO(1, 222, 234, .8),
  800: const Color.fromRGBO(1, 222, 234, .9),
  900: const Color.fromRGBO(1, 222, 234, 1),
};

abstract class CustomColors {
  //static Color red = Colors.red.shade700;

  /// Ciano da logo, usado como cor de destaque (app bar, botões) em
  /// ambos os temas claro e escuro.
  static const Color brand = Color(_brandValue);

  static MaterialColor primary = MaterialColor(_brandValue, _opacidade);
}