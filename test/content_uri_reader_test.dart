// Testes do ContentUriReader: garante que os três formatos que o scanner de
// documentos pode devolver (caminho puro, file:// e content://) sejam
// tratados corretamente.
//
// Regressão coberta aqui: o scanner do Google Play Services devolve
// `file:///data/.../pagina.jpg` em alguns aparelhos. Passar essa string
// direto para `File(...)` lança PathNotFoundException — era a causa da
// miniatura quebrada e do erro "Não foi possível gerar o PDF".

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ds_pdf/src/services/content_uri_reader.dart';

void main() {
  late Directory tempDir;
  late File arquivo;
  final conteudo = Uint8List.fromList([1, 2, 3, 4, 5]);

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ds_pdf_uri_test');
    arquivo = File('${tempDir.path}/pagina.jpg')..writeAsBytesSync(conteudo);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('lê um caminho de arquivo puro', () async {
    expect(await ContentUriReader.readBytes(arquivo.path), conteudo);
  });

  test('lê uma URI file:// (formato devolvido pelo scanner no Android)',
      () async {
    final uri = arquivo.uri.toString();
    expect(uri, startsWith('file://'));
    expect(await ContentUriReader.readBytes(uri), conteudo);
  });

  test('lê uma URI file:// com caracteres escapados (%20)', () async {
    final comEspaco = File('${tempDir.path}/pagina escaneada.jpg')
      ..writeAsBytesSync(conteudo);
    final uri = comEspaco.uri.toString();
    expect(uri, contains('%20'));
    expect(await ContentUriReader.readBytes(uri), conteudo);
  });

  test('propaga erro quando o arquivo não existe', () {
    expect(
      () => ContentUriReader.readBytes('${tempDir.path}/nao_existe.jpg'),
      throwsA(isA<FileSystemException>()),
    );
  });
}
