

//SettingsAppRepositoryInterface repository = SettingsAppRepository();

String? baseUrl;

Future<void> initializeApp() async {
 // baseUrl = await repository.getBaseUrl();
}

abstract class Endpoints {
  // Use um getter para garantir que o login seja gerado dinamicamente
  static String get login => '${baseUrl ?? ""}/login';
  static String get grupoAlmoxarifado => '${baseUrl ?? ""}/api/v1/grupo-almoxarifado';
  static String get recebimentoCompraNF => '${baseUrl ?? ""}/api/v1/recebimento-de-compra/notas-fiscais';
  static String get pedidoVenda => '${baseUrl ?? ""}/api/v1/faturamento/pedido-venda';
  static String get logErrosAplicativo => '${baseUrl ?? ""}/api/v1/log-erros-aplicativo';
  static String get itemPedidoVenda => '${baseUrl ?? ""}/api/v1/faturamento/item-pedido-venda';

}