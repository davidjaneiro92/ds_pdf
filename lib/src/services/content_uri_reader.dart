import 'dart:io';

import 'package:flutter/services.dart';

/// Lê os bytes de uma URI/caminho retornado por plugins nativos (ex.:
/// páginas do scanner de documentos).
///
/// No Android, o scanner retorna URIs "content://", que não são caminhos de
/// arquivo de verdade — não dá pra abrir com `File(...).readAsBytes()`.
/// Precisam ser lidas via `ContentResolver` nativo (implementado em
/// `MainActivity.kt`). Em outras plataformas (iOS, etc.), o plugin já
/// devolve um caminho de arquivo normal, lido direto do disco.
class ContentUriReader {
  static const MethodChannel _channel =
      MethodChannel('com.dsdevsolucoes.dspdf/content_resolver');

  static Future<Uint8List> readBytes(String uriOuCaminho) async {
    if (!uriOuCaminho.startsWith('content://')) {
      return File(uriOuCaminho).readAsBytes();
    }

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
  }
}
