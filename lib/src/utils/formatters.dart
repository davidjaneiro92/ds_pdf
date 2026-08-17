import 'dart:io';

import 'package:intl/intl.dart';

/// Formatação de metadados de arquivo usada em Início (Recentes) e Meus
/// Arquivos — ver `especificacao/replanejamento/` (documento de referência
/// do replanejamento visual, 2026-08-16), telas R1 e R5: "4 pág · 1,2 MB ·
/// hoje 09:12".
abstract class Formatters {
  static String tamanhoArquivo(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(mb < 10 ? 1 : 0).replaceAll('.', ',')} MB';
  }

  static const _mesesAbreviados = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  // Formatação manual (sem `initializeDateFormatting`, que exigiria
  // inicialização extra em main.dart e nos testes) — os tokens numéricos
  // de DateFormat (HH:mm) não precisam de dados de localidade, mas
  // nomes de mês/dia da semana precisariam.
  static String dataRelativa(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(data.year, data.month, data.day);
    final diferenca = hoje.difference(dia).inDays;

    final hora = DateFormat('HH:mm').format(data);
    if (diferenca == 0) return 'hoje $hora';
    if (diferenca == 1) return 'ontem $hora';
    return '${data.day} ${_mesesAbreviados[data.month - 1]}';
  }

  static String paginas(int pageCount) {
    if (pageCount <= 0) return 'PDF';
    return pageCount == 1 ? '1 pág' : '$pageCount pág';
  }

  /// Prévia do nome de arquivo mostrada antes de gerar (ex.: "scan_16ago"),
  /// já que o nome final real só é definido no momento de salvar
  /// (`ds_pdf_scan_<timestamp_em_ms>.pdf`, para garantir unicidade).
  static String sugestaoNomeArquivo(String prefixo) {
    final agora = DateTime.now();
    return '${prefixo}_${agora.day}${_mesesAbreviados[agora.month - 1]}';
  }

  /// Tamanho do arquivo em `path`, já formatado (ex.: "1,2 MB"), ou `null`
  /// se o arquivo não existir mais em disco (ex.: apagado fora do app) —
  /// nesse caso a chamadora deve omitir o tamanho em vez de quebrar a tela.
  static String? tamanhoArquivoDoPath(String path) {
    try {
      return tamanhoArquivo(File(path).lengthSync());
    } catch (_) {
      return null;
    }
  }

  /// Metadados de um documento numa única linha: "N pág · tamanho · data".
  static String metadadosDocumento({
    required int pageCount,
    required String path,
    required DateTime createdAt,
  }) {
    final tamanho = tamanhoArquivoDoPath(path);
    return [
      paginas(pageCount),
      if (tamanho != null) tamanho,
      dataRelativa(createdAt),
    ].join(' · ');
  }
}
