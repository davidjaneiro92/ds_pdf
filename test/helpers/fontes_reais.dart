import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registra fontes reais do sistema sob os nomes de família que o
/// `google_fonts` injeta no tema do app.
///
/// Por que isto existe: em `flutter test` não há rede, então o
/// `google_fonts` falha em baixar Barlow/Barlow Condensed/Roboto Mono e o
/// texto renderiza com a fonte padrão de teste, que é **bem mais larga**
/// que as reais. Qualquer asserção de layout numa tela apertada passa a
/// acusar estouros que não existem no aparelho (aconteceu duas vezes já —
/// ver specs/CHANGELOG.md, 2026-08-18 e 2026-09-05).
///
/// Os nomes das famílias (`Barlow_regular` etc.) são os que o
/// `google_fonts` gera internamente; foram descobertos imprimindo
/// `AppTheme.light.textTheme.titleMedium?.fontFamily`.
///
/// Silencioso quando os arquivos não existem (outra máquina, CI Linux) —
/// aí o teste volta a medir com a fonte padrão, que é o comportamento
/// conservador: acusa estouro a mais, nunca a menos.
Future<void> registrarFontesReais(WidgetTester tester) async {
  const arquivos = <String, String>{
    'BarlowCondensed_regular': r'C:\Windows\Fonts\segoeuil.ttf',
    'Barlow_regular': r'C:\Windows\Fonts\segoeui.ttf',
    'RobotoMono_regular': r'C:\Windows\Fonts\consola.ttf',
  };

  await tester.runAsync(() async {
    for (final entrada in arquivos.entries) {
      final arquivo = File(entrada.value);
      if (!arquivo.existsSync()) continue;
      final carregador = FontLoader(entrada.key)
        ..addFont(
          Future.value(ByteData.sublistView(arquivo.readAsBytesSync())),
        );
      await carregador.load();
    }
  });
}
