import 'package:hive/hive.dart';

/// Flag de primeira execução, guardada na mesma box `app_settings` do
/// [ThemeController] (já aberta em `main.dart` antes de `runApp`, então
/// pode ser lida de forma síncrona aqui — mesmo padrão de persistência).
abstract class OnboardingPrefs {
  static const _boxName = 'app_settings';
  static const _chave = 'onboardingSeen';

  static bool get visto => (Hive.box(_boxName).get(_chave) as bool?) ?? false;

  static Future<void> marcarVisto() async {
    await Hive.box(_boxName).put(_chave, true);
  }
}
