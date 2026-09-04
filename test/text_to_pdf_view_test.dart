// Regressão: a tela Texto→PDF (editor de texto rico) já quebrou 3 vezes por
// erros de layout que só aparecem em runtime (Container com color+decoration
// juntos, Spacer dentro de um Row de largura não-limitada,
// minimumSize com largura infinita no tema global — ver
// specs/CHANGELOG.md, 2026-08-17). flutter analyze não pega nenhum dos três,
// porque são válidos para o compilador; só estouram durante o layout. Este
// teste garante que abrir a tela, digitar e aplicar uma formatação não
// lançam nenhuma exceção.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:ds_pdf/src/components/loading/controller/loading_controller.dart';
import 'package:ds_pdf/src/config/app_theme.dart';
import 'package:ds_pdf/src/config/theme_controller.dart';
import 'package:ds_pdf/src/pages/text_to_pdf/controller/text_to_pdf_controller.dart';
import 'package:ds_pdf/src/pages/text_to_pdf/view/text_to_pdf_view.dart';
import 'package:ds_pdf/src/repositories/pdf_documents_repository.dart';

void main() {
  testWidgets('Texto→PDF abre e reage a digitação/negrito sem lançar exceção',
      (tester) async {
    // Largura de celular, não os 800x600 padrão do flutter_test: vários
    // dos bugs de layout desta tela (rodapé estourando, barra de
    // formatação) só aparecem em tela estreita.
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final tempDir = Directory.systemTemp.createTempSync('ds_pdf_test');
    final repo = PdfDocumentsRepository();
    final themeController = ThemeController();
    await tester.runAsync(() async {
      Hive.init(tempDir.path);
      await repo.init();
      await themeController.init();
    });
    addTearDown(() => tester.runAsync(() async {
          await Hive.close();
          tempDir.deleteSync(recursive: true);
        }));

    Get.put(repo);
    Get.put(themeController);
    Get.put(LoadingController());
    final controller = Get.put(TextToPdfController());
    addTearDown(Get.reset);

    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light,
      home: const TextToPdfView(),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'abrir a tela não deveria lançar nada');

    controller.quillController.replaceText(
      0,
      0,
      'Teste',
      const TextSelection.collapsed(offset: 5),
    );
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'digitar não deveria lançar nada');

    // avança o debounce de 400ms do recálculo de contadores
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull,
        reason: 'o recálculo de contadores (debounce) não deveria lançar nada');

    controller.quillController.formatSelection(Attribute.bold);
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'aplicar negrito não deveria lançar nada');
  });
}
