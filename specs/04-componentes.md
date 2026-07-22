# Componentes, Temas e Estilos

## Widgets reutilizáveis (`lib/src/components/`)

| Componente | Arquivo | Descrição | Observações |
|---|---|---|---|
| `CustomAppBar` | [custom_app_bar.dart](../lib/src/components/custom_app_bar.dart) | AppBar padrão do app: sempre com botão de voltar (`Get.back()`), título centralizado opcional, cor de fundo `CustomColors.blue`. | Parâmetro `golBack` existe mas não controla nada hoje (o botão voltar sempre aparece) — documentado como débito técnico. |
| `CustomErrorWidget` | [custom_error_widget.dart](../lib/src/components/custom_error_widget.dart) | Tela de fallback para qualquer erro de widget não tratado, registrada em `ErrorWidget.builder` no `main.dart`. Mostra mensagem detalhada em debug e genérica em release. | — |
| `CustomListTile` | [custom_list_tile.dart](../lib/src/components/custom_list_tile.dart) | `ListTile` genérico com ícone, título, `subtitle` opcional, `trailing` opcional e `onTap` configurável. | Usado pela primeira vez nesta sessão, na lista de documentos de Meus Arquivos. `subtitle` e `onTap` foram adicionados de forma aditiva (antes `onTap` era sempre um no-op `() {}`; permanece assim como padrão quando não informado). |
| `CustomTextField` | [custom_text_field.dart](../lib/src/components/custom_text_field.dart) | Campo de texto completo: senha com mostrar/ocultar, validação, máscara/formatters, avanço automático de foco, `maxLines`/`maxLength` opcionais (`maxLength` nulo = sem limite). | Usado na tela Texto→PDF (corpo do texto com `maxLines: null`, cabeçalho/rodapé com `maxLines: 1`). Os parâmetros `maxLength`/`maxLines` foram tornados opcionais/anuláveis para viabilizar esse uso, sem quebrar compatibilidade. |
| `customAalertQuestion` / `customAalertInformation` | [custom_alert.dart](../lib/src/components/custom_alert.dart) | Funções de diálogo: pergunta sim/não e informação com "Ok". | Usada pela primeira vez nesta sessão, em Meus Arquivos (confirmação de exclusão de documento/pasta). Nome com erro de digitação ("Aalert") mantido como está para não quebrar a assinatura pública já em uso — ver backlog. |
| `CustomToast` | [custom_toast.dart](../lib/src/components/custom_toast.dart) | Toast global (`oktoast`) com 3 estados: `status.success`, `status.warner`, `status.error`. | Usado por `ScannerController`, `TextToPdfController` e `MyFilesController` (ex.: falha ao compartilhar um arquivo). `warner` é erro de digitação de "warning", mantido por compatibilidade. |
| `LoadingWidget` / `LoadingController` | [loading/](../lib/src/components/loading/) | Overlay de loading global (`Obx` sobre `isLoading.obs`), empilhado no `builder` do `GetMaterialApp`. Qualquer controller pode chamar `Get.find<LoadingController>().showLoading()/hideLoading()`. | Usado por `SelectPdfTypeContoller`, `ScannerController` e `TextToPdfController`. |

## Tema e cores

- Definido inline em [main.dart](../lib/main.dart) via `ThemeData(colorScheme: ColorScheme.fromSeed(...), useMaterial3: true)`. Não há arquivo `theme.dart` dedicado.
- **Não há dark mode** — não existe `darkTheme:` nem `themeMode:` configurado no `GetMaterialApp`. Está no roadmap (ver [07-engenharia.md](07-engenharia.md)).
- Cor principal em [custom_colors.dart](../lib/src/config/custom_colors.dart): `CustomColors.blue`, um `MaterialColor` construído a partir de `0xFF357be9`. Corrigido nesta sessão para que os tons 50–900 do mapa de opacidades usem a mesma cor base do `MaterialColor` (antes usavam um azul diferente, `0xFF003A88`) — ver [08-auditoria.md](08-auditoria.md).

## Fontes

Nenhuma fonte customizada — o app usa as fontes padrão do Material/Cupertino. A seção `fonts:` do `pubspec.yaml` está comentada. Uma futura tela de Texto→PDF provavelmente vai precisar de fontes customizadas para o PDF gerado (a lib `pdf` suporta isso via `pw.Font`).

## Assets

Todos em `assets/img/` (PNG): `camera.png`, `documento.png`, `erro3.png`, `iconepdf.png`, `image.png`. Nenhum SVG, nenhuma fonte, nenhum outro tipo de asset.
