// Regressão da tela de leitura de PDF. Mesma motivação do
// `text_to_pdf_view_test.dart`: erros de layout aqui (rodapé com navegação
// de páginas + até três botões de ação, barra de busca com contador) são
// válidos para o compilador e só estouram durante o layout, então
// `flutter analyze` não pega nenhum deles.
//
// O `SfPdfViewer` renderiza as páginas através do canal de plataforma
// `syncfusion_flutter_pdfviewer`, que não existe em `flutter test` — o
// canal é simulado abaixo devolvendo um documento de duas páginas e um PNG
// 1x1 por página. O que se testa aqui é a nossa tela em volta do
// visualizador, não o visualizador em si.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:ds_pdf/src/config/app_theme.dart';
import 'package:ds_pdf/src/config/theme_controller.dart';
import 'package:ds_pdf/src/pages/pdf_reader/controller/pdf_reader_controller.dart';
import 'package:ds_pdf/src/pages/pdf_reader/view/pdf_reader_view.dart';
import 'package:ds_pdf/src/repositories/pdf_documents_repository.dart';

/// PNG 1x1 transparente — o visualizador só precisa de bytes que
/// `decodeImageFromList` aceite.
final Uint8List _pngVazio = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAE'
  'hQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('syncfusion_flutter_pdfviewer'),
      (call) async {
        switch (call.method) {
          case 'initializePdfRenderer':
            return '2';
          case 'getPagesHeight':
            return <double>[842, 842];
          case 'getPagesWidth':
            return <double>[595, 595];
          case 'getPage':
          case 'getTileImage':
            return _pngVazio;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('syncfusion_flutter_pdfviewer'),
      null,
    );
  });

  testWidgets('o leitor abre, navega e pesquisa sem lançar exceção',
      (tester) async {
    // Largura de celular: o rodapé do leitor é o ponto mais apertado da
    // tela e os 800x600 padrão do flutter_test esconderiam um estouro.
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final tempDir = Directory.systemTemp.createTempSync('ds_pdf_reader_test');
    final arquivo = File('${tempDir.path}/documento.pdf');
    final repo = PdfDocumentsRepository();
    final themeController = ThemeController();

    await tester.runAsync(() async {
      final documento = pw.Document();
      for (var i = 1; i <= 2; i++) {
        documento.addPage(
          pw.Page(build: (context) => pw.Center(child: pw.Text('página $i'))),
        );
      }
      await arquivo.writeAsBytes(await documento.save());

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
    final controller = Get.put(
      PdfReaderController(
        PdfReaderArgs(path: arquivo.path, titulo: 'documento.pdf'),
      ),
    );
    addTearDown(Get.reset);

    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light,
      home: PdfReaderView(),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'abrir o leitor não deveria lançar nada');

    // Antes de o documento carregar o rodapé mostra "carregando...", e as
    // setas ficam desabilitadas — nenhuma das duas coisas pode quebrar o
    // layout.
    expect(find.textContaining('carregando'), findsOneWidget);

    // Simula o documento carregado: é o `onDocumentLoaded` do visualizador
    // que preenche a contagem de páginas na vida real.
    controller.totalPaginas.value = 2;
    controller.paginaAtual.value = 1;
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'mostrar a contagem de páginas não deveria lançar nada');
    expect(find.text('página 1 de 2'), findsOneWidget);

    // Um PDF externo mostra três ações no rodapé (Compartilhar/Salvar/…),
    // que é a linha mais apertada da tela.
    expect(find.text('Compartilhar'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);

    // Abrir a barra de busca insere um campo de texto acima do
    // visualizador — o ponto onde um Row sem largura limitada estouraria.
    controller.alternarBusca();
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'abrir a pesquisa não deveria lançar nada');
    expect(find.text('Pesquisar no documento'), findsOneWidget);

    controller.alternarBusca();
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'fechar a pesquisa não deveria lançar nada');

    // O SfPdfViewer agenda um timer de 500ms ao montar; sem avançar o
    // relógio o teste termina com "A Timer is still pending".
    await tester.pump(const Duration(milliseconds: 700));
  });
}
