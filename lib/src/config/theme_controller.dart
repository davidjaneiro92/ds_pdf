import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends GetxController {
  static const _boxName = 'app_settings';
  static const _chaveModo = 'themeMode';

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  late final Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final salvo = _box.get(_chaveModo) as String?;
    switch (salvo) {
      case 'light':
        themeMode.value = ThemeMode.light;
      case 'dark':
        themeMode.value = ThemeMode.dark;
      default:
        themeMode.value = ThemeMode.system;
    }
  }

  bool get isDark {
    if (themeMode.value == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  void alternar() {
    final novoModo = isDark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = novoModo;
    _box.put(_chaveModo, novoModo == ThemeMode.dark ? 'dark' : 'light');
  }
}
