import 'package:flutter/material.dart';

Map<int, Color> _opacidade = {
  50: const Color.fromRGBO(0, 58, 136, .1),
  100: const Color.fromRGBO(0, 58, 136, .2),
  200: const Color.fromRGBO(0, 58, 136, .3),
  300: const Color.fromRGBO(0, 58, 136, .4),
  400: const Color.fromRGBO(0, 58, 136, .5),
  500: const Color.fromRGBO(0, 58, 136, .6),
  600: const Color.fromRGBO(0, 58, 136, .7),
  700: const Color.fromRGBO(0, 58, 136, .8),
  800: const Color.fromRGBO(0, 58, 136, .9),
  900: const Color.fromRGBO(0, 58, 136, 1),
};

abstract class CustomColors {
  //static Color red = Colors.red.shade700;

  static MaterialColor blue = MaterialColor(0xFF357be9, _opacidade);
}