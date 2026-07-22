# Changelog

Registro de alterações relevantes do projeto. Toda alteração de negócio ou arquitetura deve ser registrada aqui.

## 2026-07-22 — Feature: Editor de PDF

### Adicionado
- Feature **Editor de PDF** (`lib/src/pages/pdf_editor/`), acessível pelo menu "Editar" de um documento em Meus Arquivos: reordenar páginas (arrastar), excluir páginas (com página mínima de 1) e carimbar uma assinatura desenhada pelo usuário. Salva sempre como um arquivo novo (`<nome_original>_editado_<timestamp>.pdf`), registrado no `PdfDocumentsRepository`.
- Dependências novas: `syncfusion_flutter_pdf` (manipulação de PDFs existentes preservando qualidade/texto vetorial — `page.createTemplate()` + `graphics.drawPdfTemplate()` para reordenar/copiar páginas, `PdfBitmap`/`drawImage()` para carimbar a assinatura) e `signature` (canvas de captura de assinatura).
- **Primeiro uso de `binding`/`Get.lazyPut` por rota no projeto**: `PdfEditorController` recebe o documento sendo editado via `Get.arguments` no momento da navegação, diferente dos demais controllers (singletons eager registrados uma vez em `main()`) — documentado em [02-arquitetura.md](02-arquitetura.md).
- Rota `pdfEditorView` registrada em `pages_routes.dart`/`app_pages.dart`.

### Escopo descartado a pedido do usuário
- **Marca d'água**: não implementada nesta sessão (removida do escopo original do Editor de PDF).
- **Assinatura digital criptográfica (PAdES)**: fora de escopo — "assinar" neste app é desenhar e carimbar uma imagem, não uma assinatura digital verificável.

### ⚠️ Aviso de licenciamento (ação do usuário, não é uma tarefa de código)
`syncfusion_flutter_pdf` é uma biblioteca comercial. A versão instalada (29.1.38) não exige chave de licença no código para funcionar sem marca d'água/aviso de trial, mas a Syncfusion exige contratualmente que quem usa a biblioteca tenha uma licença Community (gratuita, sob condições de faturamento, via cadastro em syncfusion.com) ou Comercial. Isso não foi contratado nem verificado nesta sessão — é uma responsabilidade do usuário/empresa. Ver [07-engenharia.md](07-engenharia.md#riscos).

### Documentação
- `/specs` atualizada (visão geral, arquitetura — nova seção sobre `binding`/`Get.lazyPut`, estrutura de pastas, regras de negócio, fluxo com diagrama Mermaid, engenharia/backlog/dependências/riscos).

## 2026-07-21 (4) — Feature: Meus Arquivos

### Adicionado
- Feature **Meus Arquivos** (`lib/src/pages/my_files/`): lista todos os PDFs já gerados pelo app, com pesquisa por nome, pastas, favoritos, compartilhar, renomear e excluir. Card "Meus Arquivos" adicionado à tela inicial (4º card, completando o mock original de Escanear/Foto/Texto/Meus Arquivos).
- **Primeira camada de persistência do projeto**: `hive` + `hive_flutter`, inicializados em `main.dart` (`Hive.initFlutter()`). Metadados guardados sem `TypeAdapter`/codegen — os models são serializados manualmente como `Map<String, dynamic>`.
- **Primeiras camadas `models/` e `repositories/`** do projeto: `PdfDocumentModel`, `PdfFolderModel` (`lib/src/models/`) e `PdfDocumentsRepository` (`lib/src/repositories/`), único repositório do app, expõe todas as operações sobre documentos e pastas.
- **Reconciliação automática com o disco**: ao carregar a lista de Meus Arquivos, o repositório varre `getApplicationDocumentsDirectory()` por PDFs sem metadado (ex.: gerados antes desta feature existir) e os registra automaticamente — nenhum PDF gerado pelo app fica de fora da listagem.
- Rota `myFilesView` registrada em `pages_routes.dart`/`app_pages.dart`; `MyFilesController` registrado em `main.dart`.

### Corrigido
- [CustomListTile](../lib/src/components/custom_list_tile.dart) ganhou `subtitle` e `onTap` configuráveis (antes `onTap` era sempre um no-op) — mudança aditiva, usada pela primeira vez na lista de Meus Arquivos.
- `SelectPdfTypeContoller.gerarPDF()`, `ScannerController.gerarPDF()` e `TextToPdfController.gerarPDF()`: cada um agora chama `PdfDocumentsRepository.registrarDocumento(...)` logo após salvar o PDF em disco, para que o arquivo apareça em Meus Arquivos.
- `test/widget_test.dart`: o teste travava indefinidamente ao inicializar o Hive de teste. Causa raiz: o corpo de um `testWidgets` roda sob um relógio "fake" (`fake_async`), que nunca deixa I/O assíncrono **real** (como `Hive.openBox`, que lê/escreve arquivos de verdade) completar sozinho — precisa rodar dentro de `tester.runAsync()`. Corrigido envolvendo a inicialização do Hive (e o fechamento das boxes no teardown) em `tester.runAsync()`.

### Débito técnico registrado
- `MyFilesController` não é registrado no smoke test: seu `onInit()` chama `getApplicationDocumentsDirectory()` (via reconciliação do repositório) fora de `tester.runAsync()`, sujeito ao mesmo travamento corrigido acima. Como o smoke test nunca renderiza `MyFilesView`, o controller não é necessário para o teste passar — contornado em vez de corrigido nesta sessão. Ver [07-engenharia.md](07-engenharia.md).

### Documentação
- `/specs` atualizada (visão geral, arquitetura — nova seção sobre `models`/`repositories`, estrutura de pastas, componentes, regras de negócio, fluxos com diagrama Mermaid, engenharia/backlog/dependências).

## 2026-07-21 (3) — Correção: ícone do app não estava sendo aplicado

### Corrigido
- `flutter_launcher_icons` estava configurado em `pubspec.yaml` (`image_path: "assets/icon/icon.png"`, `android: true`, `ios: true`, `min_sdk_android: 21`), mas o pacote **nunca havia sido declarado como dependência** — por isso a ferramenta nunca rodava de fato e o ícone customizado do usuário nunca era aplicado ao app (Android/iOS continuavam com o ícone padrão do `flutter create`).
- Adicionado `flutter_launcher_icons: ^0.14.4` em `dev_dependencies` (`flutter pub add --dev flutter_launcher_icons`, versão compatível com Dart 3.5.4).
- Rodado `dart run flutter_launcher_icons`, que gerou/substituiu os ícones reais: todos os `mipmap-*/ic_launcher.png` no Android e todo o `AppIcon.appiconset` no iOS (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`), a partir de `assets/icon/icon.png` (1254×1254px, fornecido pelo usuário).

## 2026-07-21 (2) — Feature: Texto → PDF

### Adicionado
- Feature **Texto → PDF** (`lib/src/pages/text_to_pdf/`): editor de texto multilinha com escolha de fonte (Helvetica/Times/Courier) e alinhamento (esquerda/centro/direita/justificado), cabeçalho e rodapé opcionais (repetidos em todas as páginas); gera PDF paginado automaticamente (`pw.MultiPage`, A4) e compartilha.
- Enums `PdfFontOption` e `PdfTextAlignOption` (`lib/src/enum/`), mapeando as opções de UI para `pw.Font`/`pw.TextAlign` do pacote `pdf` (fontes base do PDF — Helvetica/Times/Courier —, sem exigir asset `.ttf`).
- Rota `textToPdfView` registrada em `pages_routes.dart`/`app_pages.dart`; `TextToPdfController` registrado em `main.dart`.

### Corrigido
- [CustomTextField](../lib/src/components/custom_text_field.dart) ganhou suporte a `maxLines` (opcional, default `1`) e `maxLength` passou a ser anulável (`int?`, default `20`) para permitir um campo multilinha sem limite de caracteres — mudança aditiva, sem impacto nos usos existentes (nenhuma tela usava o componente antes desta sessão).
- Card "Texto" da tela de seleção: removido o estado "em breve" (`Opacity`), ligado à navegação para `TextToPdfView`.
- `test/widget_test.dart`: `TextToPdfController` adicionado à injeção de dependência do smoke test, para consistência com os demais controllers.

### Documentação
- `/specs` atualizada (visão geral, estrutura de pastas, componentes, regras de negócio, fluxos, engenharia/backlog) para refletir a nova feature.

## 2026-07-21 (1) — Fundação: specs, correção de versão, limpeza e Scanner por câmera

### Adicionado
- Pasta `/specs` com documentação SDD completa (visão geral, arquitetura, estrutura de pastas, componentes, regras de negócio, fluxos, engenharia, auditoria, este changelog).
- Feature **Scanner por câmera** (`lib/src/pages/scanner/`): captura de documentos via scanner nativo (ML Kit no Android, VisionKit no iOS), com detecção automática de bordas, correção de perspectiva e filtros feitos pela UI nativa; geração e compartilhamento de PDF a partir das páginas capturadas.
- Dependências novas: `flutter_doc_scanner` (scanner nativo), `uri_to_file` (resolve URIs de conteúdo do Android para arquivos legíveis).
- Permissão de câmera: `android.permission.CAMERA` (Android) e `NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription` (iOS).
- Rota `scannerView` registrada em `pages_routes.dart` / `app_pages.dart`.

### Corrigido
- `pubspec.yaml`: constraint de SDK desalinhada (`^3.10.0-290.4.beta`) corrigida para `>=3.5.4 <4.0.0`, alinhada ao Flutter 3.24.5/Dart 3.5.4/DevTools 2.37.3 realmente instalados.
- `flutter_lints` rebaixado de `^6.0.0` para `^5.0.0` (a v6 exige Dart `^3.8.0`, incompatível com o projeto).
- Case-sensitivity de assets: pasta `assets/Img/` renomeada para `assets/img/`, alinhando com `pubspec.yaml` e o código (bug latente que quebraria em builds Linux/Android/Web).
- `MaterialColor` de `CustomColors.blue` (`custom_colos.dart` → `custom_colors.dart`): tons de opacidade agora usam a mesma cor base do `MaterialColor` (antes usavam uma cor diferente).
- PDF gerado por Foto→PDF e Scanner→PDF agora usa nome de arquivo único (timestamp) em vez de nome fixo — evita que um novo PDF sobrescreva o anterior.
- Removidos `print()` de debug em `custom_text_field.dart` e no controller de lista genérica (removido).
- Texto duplicado/mal formatado na splash screen ("Convert Images or text to PDF files" + "text to PDF files") unificado em uma frase.
- Removido import interno desnecessário do pacote `get` (`get_core/src/get_main.dart`) em `splash_screen.dart`.
- Título do app (`main.dart`) corrigido de "Controle de Separação" (resquício de outro projeto) para "DS PDF".
- Cards "Câmera" e "Texto" da tela de seleção agora têm texto correto (antes os 3 cards diziam "Select Images"); card "Câmera" ligado ao novo fluxo do Scanner; card "Texto" marcado visualmente como "em breve".
- `test/widget_test.dart`: substituído o teste padrão do template (`flutter create`, testava um contador inexistente) por um smoke test real, incluindo a injeção de dependência necessária (`LoadingController`, `SelectPdfTypeContollerAbstract`, `ScannerController`) e o avanço do timer da splash screen para evitar timer pendente no teardown.

### Removido
- Código morto herdado de um projeto anterior não relacionado (sistema de estoque/logística): `lib/src/components/custom_Scaffold/`, `lib/src/components/custom_list_view/`, `lib/src/constants/Endpoints.dart`, `lib/src/enum/http_methods.dart`.
- Dependência `fluttertoast` (redundante com `oktoast`, sem nenhuma referência no código).
- Bloco de rota comentado (`nfsPedidos`) em `pages_routes.dart`.

### Débito técnico registrado (não corrigido, fora do escopo desta sessão)
Ver [08-auditoria.md](08-auditoria.md) e [07-engenharia.md](07-engenharia.md) — inclui nomes de arquivo/classe com erro de digitação em `select_PDF_type_*`, parâmetro `golBack` não funcional em `CustomAppBar`, componentes ainda não usados (`CustomListTile`, `CustomTextField`), e 22 avisos de lint pré-existentes.
