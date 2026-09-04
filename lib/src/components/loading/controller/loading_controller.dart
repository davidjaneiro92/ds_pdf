import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Lançada pelos controllers de geração de PDF quando o usuário cancela
/// pelo diálogo de progresso (ver [LoadingController.cancelar]) — sinaliza
/// um cancelamento voluntário, não um erro, para quem trata a exceção
/// puder mostrar um toast neutro em vez de "Não foi possível gerar o PDF.".
class GeracaoCanceladaException implements Exception {}

/// Estado exibido pelo [LoadingWidget]: em progresso (determinado ou
/// indeterminado), sucesso (arquivo gerado, com ações de acompanhamento) ou
/// erro (causa em linguagem simples + ação de recuperação opcional).
enum LoadingEstado { progresso, sucesso, erro }

/// Controla o overlay de carregamento global (ver [LoadingWidget]).
///
/// Além do progresso página-a-página cancelável, também guarda o desfecho
/// da operação (ver `especificacao/replanejamento/`, seção "Feedback de
/// sistema"): [mostrarSucesso] troca o diálogo para uma confirmação com o
/// nome do arquivo e atalhos de Compartilhar/Ver em Meus Arquivos;
/// [mostrarErro] troca para uma causa em linguagem simples com ação de
/// tentar de novo. Um único diálogo (não três) para não duplicar a lógica
/// de show/hide.
class LoadingController extends GetxController {
  final isLoading = false.obs;
  final estado = LoadingEstado.progresso.obs;
  final mensagem = ''.obs;
  final progressoAtual = Rx<int?>(null);
  final progressoTotal = Rx<int?>(null);
  final cancelavel = false.obs;
  bool _cancelado = false;

  final nomeArquivoSucesso = ''.obs;
  final causaErro = ''.obs;
  VoidCallback? _aoCompartilhar;
  VoidCallback? _aoVerEmMeusArquivos;
  VoidCallback? _aoTentarNovamente;

  VoidCallback? get aoCompartilhar => _aoCompartilhar;
  VoidCallback? get aoVerEmMeusArquivos => _aoVerEmMeusArquivos;
  VoidCallback? get aoTentarNovamente => _aoTentarNovamente;

  bool get foiCancelado => _cancelado;

  void showLoading({String mensagem = 'Carregando...', bool cancelavel = false}) {
    estado.value = LoadingEstado.progresso;
    this.mensagem.value = mensagem;
    this.cancelavel.value = cancelavel;
    progressoAtual.value = null;
    progressoTotal.value = null;
    _cancelado = false;
    isLoading.value = true;
  }

  void atualizarProgresso(int atual, int total) {
    progressoAtual.value = atual;
    progressoTotal.value = total;
  }

  /// Chamado pelo botão "Cancelar" do diálogo. Não interrompe o trabalho
  /// sozinho — os controllers de geração checam [foiCancelado] entre uma
  /// página e outra e lançam [GeracaoCanceladaException] para parar.
  void cancelar() {
    _cancelado = true;
  }

  /// Troca o diálogo (ainda visível) para o estado de sucesso, com o nome
  /// do arquivo gerado e os dois atalhos de acompanhamento.
  void mostrarSucesso({
    required String nomeArquivo,
    required VoidCallback aoCompartilhar,
    required VoidCallback aoVerEmMeusArquivos,
  }) {
    nomeArquivoSucesso.value = nomeArquivo;
    _aoCompartilhar = aoCompartilhar;
    _aoVerEmMeusArquivos = aoVerEmMeusArquivos;
    estado.value = LoadingEstado.sucesso;
    isLoading.value = true;
  }

  /// Troca o diálogo (ainda visível) para o estado de erro, com a causa em
  /// linguagem simples e uma ação de recuperação opcional.
  void mostrarErro({required String causa, VoidCallback? aoTentarNovamente}) {
    causaErro.value = causa;
    _aoTentarNovamente = aoTentarNovamente;
    estado.value = LoadingEstado.erro;
    isLoading.value = true;
  }

  void hideLoading() {
    isLoading.value = false;
    estado.value = LoadingEstado.progresso;
    _aoCompartilhar = null;
    _aoVerEmMeusArquivos = null;
    _aoTentarNovamente = null;
  }
}
