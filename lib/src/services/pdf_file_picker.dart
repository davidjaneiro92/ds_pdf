import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Seleção de um PDF já existente no aparelho, para o app **ler** (e não
/// gerar). É o caminho de entrada do botão "Abrir PDF" da tela Início.
///
/// No Android o `file_picker` devolve um caminho para uma cópia em cache do
/// arquivo escolhido — dá para abrir normalmente com `File(...)`, mas o
/// sistema pode limpar esse cache a qualquer momento. Por isso o leitor
/// oferece "Salvar em Meus Arquivos" (ver [PdfReaderController.salvarEmMeusArquivos]),
/// que copia o arquivo para o diretório do app antes de registrá-lo — e por
/// isso um PDF externo **não** entra automaticamente em Meus Arquivos: o
/// registro apontaria para um caminho que pode sumir sozinho.
abstract class PdfFilePicker {
  /// Caminho do PDF escolhido, ou `null` se o usuário cancelou (ou se o
  /// seletor devolveu algo sem caminho utilizável).
  static Future<String?> escolher() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        // `withData: false` evita carregar o arquivo inteiro na memória —
        // PDFs de dezenas de MB são comuns e o leitor abre por caminho.
        withData: false,
      );
      final caminho = resultado?.files.single.path;
      if (caminho == null || caminho.isEmpty) return null;
      return caminho;
    } catch (e) {
      debugPrint('PdfFilePicker.escolher falhou: $e');
      return null;
    }
  }
}
