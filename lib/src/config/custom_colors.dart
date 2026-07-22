import 'package:flutter/material.dart';

Map<int, Color> _opacidade = {
  50: const Color.fromRGBO(53, 123, 233, .1),
  100: const Color.fromRGBO(53, 123, 233, .2),
  200: const Color.fromRGBO(53, 123, 233, .3),
  300: const Color.fromRGBO(53, 123, 233, .4),
  400: const Color.fromRGBO(53, 123, 233, .5),
  500: const Color.fromRGBO(53, 123, 233, .6),
  600: const Color.fromRGBO(53, 123, 233, .7),
  700: const Color.fromRGBO(53, 123, 233, .8),
  800: const Color.fromRGBO(53, 123, 233, .9),
  900: const Color.fromRGBO(53, 123, 233, 1),
};

abstract class CustomColors {
  //static Color red = Colors.red.shade700;

  static MaterialColor blue = MaterialColor(0xFF357be9, _opacidade);
}