import 'package:flutter/material.dart';

import 'custom_colors.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.brand,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.brand,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
