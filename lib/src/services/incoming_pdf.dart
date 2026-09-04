import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../pages/pdf_reader/pdf_reader_launcher.dart';

/// PDFs que chegam de **fora** do app: o usuário toca num PDF no
/// gerenciador de arquivos, num anexo de e-mail ou no Downloads e escolhe o
/// DS PDF em "Abrir com" (os `intent-filter` que registram o app para isso
/// estão em `android/app/src/main/AndroidManifest.xml`).
///
/// O lado nativo (`MainActivity.kt`) copia o conteúdo recebido para um
/// arquivo no cache e devolve o caminho — o visualizador precisa de um
/// `File` de verdade, e uma `content://` URI não é um arquivo.
///
/// Dois momentos possíveis:
///
/// - o app estava **fechado** e foi aberto pelo PDF: o intent já existe
///   quando o Flutter sobe, e [verificarPendente] o consome (chamado pela
///   splash, depois de decidir a tela inicial, para o leitor empilhar por
///   cima dela e o botão de voltar levar à Início);
/// - o app já estava **aberto** (a activity é `singleTop`): o nativo avisa
///   pelo método `pdfRecebido` e abrimos na hora.
abstract class IncomingPdf {
  static const MethodChannel _channel =
      MethodChannel('com.dsdevsolucoes.dspdf/content_resolver');

  /// Registra o ouvinte para PDFs que chegam com o app já aberto. Chamar
  /// uma vez, no `main`.
  static void iniciar() {
    if (!_suportado) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pdfRecebido') {
        await verificarPendente();
      }
      return null;
    });
  }

  /// Abre o leitor se houver um PDF esperando para ser aberto. Silencioso
  /// quando não há nada — é o caso normal de toda abertura do app.
  static Future<void> verificarPendente() async {
    if (!_suportado) return;
    try {
      final caminho =
          await _channel.invokeMethod<String>('consumirPdfRecebido');
      if (caminho == null || caminho.isEmpty) return;
      await PdfReaderLauncher.abrirArquivo(caminho);
    } catch (e) {
      // Nenhum PDF recebido não é erro; qualquer falha aqui só significa
      // que o app abre normalmente na Início.
      debugPrint('IncomingPdf.verificarPendente falhou: $e');
    }
  }
}

/// O canal só existe no `MainActivity` do Android. Em desktop/web
/// invocá-lo lançaria `MissingPluginException` a cada abertura.
bool get _suportado => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
