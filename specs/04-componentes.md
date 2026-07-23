# Componentes, Temas e Estilos

## Widgets reutilizáveis (`lib/src/components/`)

| Componente | Arquivo | Descrição | Observações |
|---|---|---|---|
| `CustomAppBar` | [custom_app_bar.dart](../lib/src/components/custom_app_bar.dart) | AppBar padrão do app: sempre com botão de voltar (`Get.back()`), título centralizado opcional, cor de fundo `CustomColors.primary` (ciano da logo, fixo nos dois temas) com texto/ícones em preto (`Colors.black87`) para contraste — e um botão de alternância de tema claro/escuro no canto direito (`actions`), que chama `ThemeController.alternar()`. | Parâmetro `golBack` existe mas não controla nada hoje (o botão voltar sempre aparece) — documentado como débito técnico. |
| `CustomErrorWidget` | [custom_error_widget.dart](../lib/src/components/custom_error_widget.dart) | Tela de fallback para qualquer erro de widget não tratado, registrada em `ErrorWidget.builder` no `main.dart`. Mostra mensagem detalhada em debug e genérica em release. | — |
| `CustomListTile` | [custom_list_tile.dart](../lib/src/components/custom_list_tile.dart) | `ListTile` genérico com ícone, título, `subtitle` opcional, `trailing` opcional e `onTap` configurável. | Usado pela primeira vez nesta sessão, na lista de documentos de Meus Arquivos. `subtitle` e `onTap` foram adicionados de forma aditiva (antes `onTap` era sempre um no-op `() {}`; permanece assim como padrão quando não informado). |
| `CustomTextField` | [custom_text_field.dart](../lib/src/components/custom_text_field.dart) | Campo de texto completo: senha com mostrar/ocultar, validação, máscara/formatters, avanço automático de foco, `maxLines`/`maxLength` opcionais (`maxLength` nulo = sem limite), `expands` opcional (padrão `false`) para preencher a altura de um `SizedBox`/`Expanded` pai (usa `TextFormField.expands`, força `maxLines`/`minLines` nulos internamente quando ativo). | Usado na tela Texto→PDF (corpo do texto com `expands: true` dentro de um `SizedBox(height: 50% da tela)`, cabeçalho/rodapé com `maxLines: 1`). Os parâmetros `maxLength`/`maxLines`/`expands` foram tornados opcionais para viabilizar esses usos, sem quebrar compatibilidade. |
| `customAalertQuestion` / `customAalertInformation` | [custom_alert.dart](../lib/src/components/custom_alert.dart) | Funções de diálogo: pergunta sim/não e informação com "Ok". | Usada pela primeira vez nesta sessão, em Meus Arquivos (confirmação de exclusão de documento/pasta). Nome com erro de digitação ("Aalert") mantido como está para não quebrar a assinatura pública já em uso — ver backlog. |
| `CustomToast` | [custom_toast.dart](../lib/src/components/custom_toast.dart) | Toast global (`oktoast`) com 3 estados: `status.success`, `status.warner`, `status.error`. | Usado por `ScannerController`, `TextToPdfController` e `MyFilesController` (ex.: falha ao compartilhar um arquivo). `warner` é erro de digitação de "warning", mantido por compatibilidade. |
| `LoadingWidget` / `LoadingController` | [loading/](../lib/src/components/loading/) | Overlay de loading global (`Obx` sobre `isLoading.obs`), empilhado no `builder` do `GetMaterialApp`. Qualquer controller pode chamar `Get.find<LoadingController>().showLoading()/hideLoading()`. | Usado por `SelectPdfTypeContoller`, `ScannerController` e `TextToPdfController`. |

## Tema e cores

- `ThemeData` claro/escuro definidos em [app_theme.dart](../lib/src/config/app_theme.dart) (`AppTheme.light`/`AppTheme.dark`), ambos via `ColorScheme.fromSeed(seedColor: CustomColors.brand, brightness: ...)`. `main.dart` passa os dois ao `GetMaterialApp` (`theme`/`darkTheme`) e escolhe qual está ativo com `themeMode: themeController.themeMode.value`, dentro de um `Obx` (rebuild automático ao trocar o tema).
- **Dark mode implementado** (2026-07-23): [theme_controller.dart](../lib/src/config/theme_controller.dart) guarda o `ThemeMode` ativo (padrão: `ThemeMode.system`) e persiste a escolha explícita do usuário em Hive (box `app_settings`). Alternado pelo botão de sol/lua no `CustomAppBar`.
- Cor principal em [custom_colors.dart](../lib/src/config/custom_colors.dart): `CustomColors.brand`/`CustomColors.primary`, um ciano (`0xFF01DEEA`) extraído por amostragem de pixel do ícone do app (`assets/icon/icon.png`) — substituiu o azul genérico usado antes (`0xFF357be9`), a pedido do usuário para a identidade visual seguir a cor da logo. Mantida fixa (não varia por tema) em componentes de destaque (app bar, botões primários), com texto/ícones em `Colors.black87` em vez de branco, já que o ciano é uma cor clara e branco sobre ela teria baixo contraste.

## Fontes

Nenhuma fonte customizada — o app usa as fontes padrão do Material/Cupertino. A seção `fonts:` do `pubspec.yaml` está comentada. Uma futura tela de Texto→PDF provavelmente vai precisar de fontes customizadas para o PDF gerado (a lib `pdf` suporta isso via `pw.Font`).

## Assets

Todos em `assets/img/` (PNG): `camera.png`, `documento.png`, `erro3.png`, `iconepdf.png`, `image.png`. Nenhum SVG, nenhuma fonte, nenhum outro tipo de asset.
