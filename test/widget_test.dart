// Smoke test: verifica que o app inicializa sem lançar erros e mostra a splash screen.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:ds_pdf/main.dart';
import 'package:ds_pdf/src/components/loading/controller/loading_controller.dart';
import 'package:ds_pdf/src/pages/scanner/controller/scanner_controller.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/abstract/select_PDF_type_contoller_abstract.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/controller/select_PDF_type_contoller.dart';
import 'package:ds_pdf/src/pages/text_to_pdf/controller/text_to_pdf_controller.dart';
import 'package:ds_pdf/src/repositories/pdf_documents_repository.dart';

void main() {
  testWidgets('App inicializa e mostra a splash screen', (WidgetTester tester) async {
    // Hive.initFlutter() depende de path_provider (platform channel), que não
    // existe em testes de widget puros. Usamos um diretório temporário real
    // (dart:io) no lugar dele.
    //
    // O I/O real do Hive (abrir as boxes) precisa rodar dentro de
    // tester.runAsync(): o corpo de testWidgets roda sob um relógio "fake"
    // (fake_async), que nunca deixa I/O assíncrono de verdade completar —
    // sem runAsync, `Hive.openBox` trava para sempre.
    final tempDir = Directory.systemTemp.createTempSync('ds_pdf_test');
    final pdfDocumentsRepository = PdfDocumentsRepository();
    await tester.runAsync(() async {
      Hive.init(tempDir.path);
      await pdfDocumentsRepository.init();
    });
    addTearDown(() => tester.runAsync(() async {
          await Hive.close();
          tempDir.deleteSync(recursive: true);
        }));

    // Mesma injeção de dependência feita em main(), necessária porque
    // LoadingWidget (sempre presente no builder do GetMaterialApp) depende
    // de LoadingController já estar registrado.
    //
    // MyFilesController não é registrado aqui: seu onInit() chama
    // getApplicationDocumentsDirectory() (via PdfDocumentsRepository) fora do
    // tester.runAsync() acima, correndo o mesmo risco de travar. Como este
    // smoke test nunca navega até MyFilesView, o controller não é necessário.
    Get.put(pdfDocumentsRepository);
    Get.put(LoadingController());
    Get.put<SelectPdfTypeContollerAbstract>(SelectPdfTypeContoller());
    Get.put(ScannerController());
    Get.put(TextToPdfController());
    addTearDown(Get.reset);

    await tester.pumpWidget(const MyApp());

    expect(find.text('PDF Generator'), findsOneWidget);

    // Avança o relógio do teste para além do delay de 2s da splash screen,
    // evitando que o Timer fique pendente ao final do teste.
    await tester.pump(const Duration(seconds: 3));
  });
}
