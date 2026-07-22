# Engenharia

## Convenções observadas

- Nomes de arquivo `snake_case`, classes `UpperCamelCase`, controllers sufixados com `Controller`.
- Um controller por feature, opcionalmente com uma interface `abstract` para permitir troca de implementação/mock em testes (não usado em testes hoje, mas é o padrão do projeto).
- Textos de UI e mensagens de erro em português; nomes de classes/métodos em português também (`selecionarImagens`, `gerarPDF`, `escanearDocumento`), mesmo com o restante do código (Flutter/Dart) em inglês — é o padrão consistente do projeto, mantido nas novas features.
- Widgets de tela são sempre `StatelessWidget` que buscam o controller via `Get.find()`; estado fica inteiramente no `GetxController`.

## Débito técnico conhecido (não corrigido nesta sessão, por estar fora do escopo combinado)

| Item | Onde | Descrição |
|---|---|---|
| Nome de arquivo/classe com erro de digitação | `select_PDF_type_contoller.dart`, `SelectPdfTypeContoller`, `select_PDF_type_contoller_abstract.dart` | "Contoller" em vez de "Controller". Não renomeado para não introduzir um diff de rename desnecessariamente grande fora do escopo desta sessão. |
| `customAalertQuestion` / `customAalertInformation` | `custom_alert.dart` | Nome com erro de digitação ("Aalert"). Não usado em nenhuma tela hoje — renomear quando for adotado. |
| `CustomAppBar.golBack` | `custom_app_bar.dart` | Parâmetro existe mas não controla o botão de voltar (`automaticallyImplyLeading` fixo em `false`, leading sempre presente). |
| `CustomListTile.onTap` | `custom_list_tile.dart` | Vazio e não configurável via parâmetro; componente não usado em nenhuma tela ainda. |
| Import interno do GetX | `custom_app_bar.dart` | `import 'package:get/get_core/src/get_main.dart'` é um import profundo desnecessário (tudo já vem de `package:get/get.dart`); flagado pelo `flutter analyze` como `unnecessary_import`. |
| Vários lints `info` (SizedBox em vez de Container para espaçamento, `super.key`, interpolação de string desnecessária) | `custom_alert.dart`, `custom_error_widget.dart`, `custom_list_tile.dart`, `custom_text_field.dart`, `loading.dart` | Nenhum é erro; listados via `flutter analyze` (22 avisos restantes, todos em código pré-existente não tocado nas sessões de fundação e Texto→PDF). |
| `CustomToast.status` | `custom_toast.dart` | Nome de tipo `status` (minúsculo) colide estilisticamente com o parâmetro de mesmo nome; lint `camel_case_types`. Mantido para não quebrar a API pública já adotada por `ScannerController` e `TextToPdfController`. |
| Controllers sempre "eager" (`Get.put` direto em `main()`) | `main.dart` | Funciona bem no tamanho atual do app; se o número de features crescer, considerar `Get.lazyPut` ou bindings por rota (`GetPage.binding`). |
| `MyFilesController` não é testado pelo smoke test | `test/widget_test.dart` | `onInit()` chama `getApplicationDocumentsDirectory()` (via `PdfDocumentsRepository._reconciliarComDisco`) **fora** de `tester.runAsync()` — dentro do corpo de um `testWidgets`, qualquer I/O assíncrono real (arquivo, platform channel) precisa rodar dentro de `tester.runAsync()`, porque o corpo do teste roda sob um relógio "fake" (`fake_async`) que nunca deixa I/O real completar sozinho; sem isso, o `await` trava para sempre (foi exatamente o que aconteceu com `Hive.openBox` antes de mover a inicialização do Hive para dentro de `runAsync` — ver [CHANGELOG.md](CHANGELOG.md)). Contornado não registrando `MyFilesController` no smoke test, já que ele nunca renderiza `MyFilesView`. Se um teste de widget precisar cobrir Meus Arquivos no futuro, a chamada de `carregar()` (e portanto o `Get.put` que a dispara via `onInit`) precisa acontecer dentro de `tester.runAsync()`. |

## Dependências e versões (pós-atualização desta sessão)

| Pacote | Versão fixada | Observação |
|---|---|---|
| Flutter SDK | 3.24.5 (stable) | Já era a versão instalada na máquina; `pubspec.yaml` estava com uma constraint desalinhada (`^3.10.0-290.4.beta`), corrigida para `>=3.5.4 <4.0.0`. |
| Dart SDK | 3.5.4 | — |
| DevTools | 2.37.3 | — |
| `get` | ^4.6.6 | Sem mudança. |
| `pdf` | ^3.10.7 | Sem mudança. |
| `printing` | ^5.12.0 | Sem mudança. |
| `image_picker` | ^1.0.7 | Sem mudança. |
| `path_provider` | ^2.1.2 | Sem mudança. |
| `permission_handler` | ^11.1.0 | Sem mudança. |
| `oktoast` | ^3.4.0 | Sem mudança. |
| `intl` | ^0.19.0 | Sem mudança. |
| `flutter_doc_scanner` | ^0.0.21 | **Novo** — scanner nativo (ML Kit/VisionKit) para a feature Scanner. |
| `uri_to_file` | ^1.0.0 | **Novo** — resolve URIs de conteúdo (Android `content://`) retornadas pelo scanner para arquivos legíveis via `dart:io`. |
| `fluttertoast` | — | **Removido** — redundante com `oktoast`, que é a lib de toast efetivamente usada pelo `CustomToast`; nenhuma referência a `fluttertoast` existia no código. |
| `flutter_lints` (dev) | ^5.0.0 (era ^6.0.0) | `flutter_lints ^6.0.0` exige Dart `^3.8.0`, incompatível com o Dart 3.5.4 do projeto. Rebaixado para a versão mais recente compatível. |
| `flutter_launcher_icons` (dev) | ^0.14.4 | **Novo** — gera o ícone nativo do app (Android/iOS) a partir de `assets/icon/icon.png`. A configuração já existia em `pubspec.yaml`, mas o pacote nunca havia sido declarado como dependência, então o ícone nunca era de fato gerado — ver [CHANGELOG.md](CHANGELOG.md). |
| `hive` | ^2.2.3 | **Novo** — persistência local dos metadados de documentos/pastas (Meus Arquivos). |
| `hive_flutter` | ^1.1.0 | **Novo** — inicialização do Hive integrada ao Flutter (`Hive.initFlutter()` em `main.dart`, usa `path_provider` internamente). |
| `syncfusion_flutter_pdf` | ^29.1.38 | **Novo** — manipulação de PDFs existentes (reordenar/excluir páginas, carimbar assinatura) no Editor de PDF, preservando qualidade/texto vetorial. **Biblioteca comercial** — ver aviso de licenciamento abaixo em Riscos. |
| `signature` | ^5.5.0 | **Novo** — captura de assinatura desenhada (canvas) no Editor de PDF. MIT, leve, sem questões de licenciamento. |

## Riscos

- **`flutter_doc_scanner` é um pacote pequeno/comunitário** (não é um pacote oficial do Google/Flutter), embora envolva as APIs nativas oficiais (ML Kit Document Scanner, VisionKit). Se ele parar de ser mantido, a alternativa é trocar por outro wrapper equivalente (`aio_scanner`, `flutter_docs_scanner`) sem reescrever a lógica de negócio do `ScannerController` (a troca ficaria isolada nesse arquivo).
- **`uri_to_file`** não tem release recente (~2 anos), mas resolve um problema estrutural do Android (URIs `content://`) sem alternativa mais simples dentro do escopo desta sessão. Se causar problemas em produção, a alternativa é escrever um platform channel próprio para `ContentResolver.openInputStream()`.
- **Build de release Android** ainda assina com a chave de debug (`signingConfig = signingConfigs.getByName("debug")` em `android/app/build.gradle.kts`) — bloqueia publicação na Play Store até ser configurado um keystore de release.
- **`applicationId`** ainda é o padrão gerado pelo `flutter create` (`com.dsdev.pdf.ds_pdf`) — validar se é o identificador definitivo antes de publicar.
- **Licenciamento do `syncfusion_flutter_pdf` (⚠️ ação necessária do usuário/empresa, não é algo que o código resolva)**: é uma biblioteca comercial. A partir da versão usada nesta sessão (≥18.3.35, e a instalada é 29.1.38), **não é mais necessário registrar uma chave de licença no código** — o pacote funciona tecnicamente sem isso, sem marca d'água/aviso de trial nos PDFs gerados. Porém, contratualmente, a Syncfusion exige que quem usa a biblioteca tenha uma licença: **Community** (gratuita, para indivíduos ou empresas com faturamento anual abaixo de um limite definido pela Syncfusion, mediante cadastro em syncfusion.com) ou **Comercial**. Isso não foi verificado nem contratado por mim — é uma obrigação legal do lado de quem publica o app, que só o usuário pode resolver.

## Backlog (funcionalidades futuras)

1. Dark mode (`darkTheme` + `themeMode` no `GetMaterialApp`).
2. Testes automatizados além do smoke test atual (testes de controller/repositório com mocks, ex.: `ScannerController.gerarPDF`, `PdfDocumentsRepository` com Hive em memória, `PdfEditorController.salvar` com um PDF de teste).
3. Assinatura de release Android + revisão do `applicationId`.
4. Texto → PDF: fontes TrueType customizadas (hoje só as 3 fontes base do PDF), suporte a negrito/itálico, tamanho de fonte configurável.
5. Meus Arquivos: renomear pasta pela UI (a capacidade já existe no repositório — `renomearPasta` —, só falta expor no `MyFilesController`/`MyFilesView`), ordenação da lista (hoje é sempre por data de criação decrescente), seleção múltipla para excluir/mover vários documentos de uma vez.
6. Editor de PDF: marca d'água (descartada nesta sessão a pedido do usuário, pode voltar como melhoria opcional), reposicionamento arrastável da assinatura (hoje é sempre fixa no canto inferior direito), redimensionar a assinatura antes de carimbar.
