import 'package:get/get.dart';

/// Lançada pelos controllers de geração de PDF quando o usuário cancela
/// pelo diálogo de progresso (ver [LoadingController.cancelar]) — sinaliza
/// um cancelamento voluntário, não um erro, para quem trata a exceção
/// puder mostrar um toast neutro em vez de "Não foi possível gerar o PDF.".
class GeracaoCanceladaException implements Exception {}

/// Controla o overlay de carregamento global (ver [LoadingWidget]).
///
/// Suporta dois modos: indeterminado (spinner simples, ex.: carregando
/// páginas do editor) e determinado com progresso página-a-página e
/// cancelamento (ex.: gerando PDF — ver `especificacao/replanejamento/`,
/// tela R7 "Feedback — progresso determinado e cancelável").
class LoadingController extends GetxController {
  final isLoading = false.obs;
  final mensagem = ''.obs;
  final progressoAtual = Rx<int?>(null);
  final progressoTotal = Rx<int?>(null);
  final cancelavel = false.obs;
  bool _cancelado = false;

  bool get foiCancelado => _cancelado;

  void showLoading({String mensagem = 'Carregando...', bool cancelavel = false}) {
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

  void hideLoading() {
    isLoading.value = false;
  }
}
