// Regressão do diálogo global de progresso/sucesso/erro.
//
// Bug real (2026-09-05, reportado pelo usuário no fluxo do Scanner):
// os três botões de ação chamavam `hideLoading()` **antes** de ler o
// callback, e `hideLoading()` zera os três callbacks. O resultado era
// `null?.call()` — o diálogo fechava e nada acontecia: não compartilhava,
// não navegava, não tentava de novo. Silencioso, porque `?.call()` num
// nulo é perfeitamente legal em Dart, então nem `flutter analyze` nem o
// runtime reclamavam.
//
// Afetava os três fluxos de geração de PDF (Scanner, Galeria e Texto),
// que usam este mesmo diálogo.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ds_pdf/src/components/loading/controller/loading_controller.dart';
import 'package:ds_pdf/src/components/loading/view/loading.dart';
import 'package:ds_pdf/src/config/app_theme.dart';

import 'helpers/fontes_reais.dart';

Future<LoadingController> _montarDialogo(WidgetTester tester) async {
  await registrarFontesReais(tester);
  // Largura de celular — o diálogo tem no máximo 340px e as linhas de dois
  // botões são o ponto apertado.
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final controller = Get.put(LoadingController());
  addTearDown(Get.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: LoadingWidget()),
  ));
  return controller;
}

void main() {
  testWidgets('"Compartilhar" dispara a ação e fecha o diálogo',
      (tester) async {
    final controller = await _montarDialogo(tester);

    var compartilhou = 0;
    controller.mostrarSucesso(
      nomeArquivo: 'ds_pdf_scan_123.pdf',
      aoCompartilhar: () => compartilhou++,
      aoVerEmMeusArquivos: () {},
    );
    await tester.pump();
    expect(find.text('ds_pdf_scan_123.pdf'), findsOneWidget);

    await tester.tap(find.text('Compartilhar'));
    await tester.pump();

    expect(compartilhou, 1, reason: 'o callback tem que ser chamado');
    expect(controller.isLoading.value, isFalse,
        reason: 'o diálogo tem que fechar');
  });

  testWidgets('"Ver em Meus Arquivos" dispara a ação e fecha o diálogo',
      (tester) async {
    final controller = await _montarDialogo(tester);

    var navegou = 0;
    controller.mostrarSucesso(
      nomeArquivo: 'ds_pdf_scan_123.pdf',
      aoCompartilhar: () {},
      aoVerEmMeusArquivos: () => navegou++,
    );
    await tester.pump();

    await tester.tap(find.text('Ver em Meus Arquivos'));
    await tester.pump();

    expect(navegou, 1, reason: 'o callback tem que ser chamado');
    expect(controller.isLoading.value, isFalse);
  });

  testWidgets('"Tentar de novo" dispara a ação e fecha o diálogo',
      (tester) async {
    final controller = await _montarDialogo(tester);

    var tentou = 0;
    controller.mostrarErro(
      causa: 'Sem espaço em disco.',
      aoTentarNovamente: () => tentou++,
    );
    await tester.pump();
    expect(find.text('Sem espaço em disco.'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    expect(tentou, 1, reason: 'o callback tem que ser chamado');
    expect(controller.isLoading.value, isFalse);
  });

  testWidgets('erro sem ação de recuperação mostra só "Fechar"',
      (tester) async {
    final controller = await _montarDialogo(tester);

    controller.mostrarErro(causa: 'Falhou.');
    await tester.pump();

    expect(find.text('Tentar de novo'), findsNothing);
    await tester.tap(find.text('Fechar'));
    await tester.pump();
    expect(controller.isLoading.value, isFalse);
  });
}
