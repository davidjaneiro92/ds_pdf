import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Lê os bytes de uma URI/caminho retornado por plugins nativos (ex.:
/// páginas do scanner de documentos).
///
/// O scanner pode devolver três formatos diferentes, dependendo da
/// plataforma/versão do Google Play Services:
///
/// - `content://...` — URI de conteúdo do Android; não é um arquivo de
///   verdade, precisa ser lida via `ContentResolver` nativo (implementado
///   em `MainActivity.kt`).
/// - `file:///...` — URI de arquivo; é um arquivo real no disco, mas o
///   prefixo `file://` precisa ser removido antes de abrir com `File(...)`,
///   senão vira um caminho inválido (`PathNotFoundException`).
/// - `/data/...` — caminho de arquivo puro, aberto direto.
class ContentUriReader {
  static const MethodChannel _channel =
      MethodChannel('com.dsdevsolucoes.dspdf/content_resolver');

  static Future<Uint8List> readBytes(String uriOuCaminho) async {
    if (!uriOuCaminho.startsWith('content://')) {
      // `file:///caminho` → `/caminho`. Também decodifica %20 etc., já que
      // URIs escapam caracteres que são válidos num caminho de arquivo.
      final caminho = uriOuCaminho.startsWith('file://')
          ? Uri.parse(uriOuCaminho).toFilePath()
          : uriOuCaminho;
      try {
        return await File(caminho).readAsBytes();
      } catch (e) {
        debugPrint('ContentUriReader.readBytes falhou para "$caminho": $e');
        rethrow;
      }
    }

    try {
      final bytes = await _channel.invokeMethod<Uint8List>(
        'readBytes',
        {'uri': uriOuCaminho},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw Exception('Tempo esgotado ao ler a página escaneada.'),
      );

      if (bytes == null) {
        throw Exception('Não foi possível ler a página escaneada.');
      }
      return bytes;
    } catch (e) {
      debugPrint('ContentUriReader.readBytes falhou para "$uriOuCaminho": $e');
      rethrow;
    }
  }
}
