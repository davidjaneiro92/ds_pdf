# Changelog

Registro de alterações relevantes do projeto. Toda alteração de negócio ou arquitetura deve ser registrada aqui.

## 2026-08-16 — Correção real do bug do Scanner (`file://`) + replanejamento visual (telas simples)

Sessão retomada depois de um hiato: o usuário reportou de novo erro ao escanear/gerar PDF (miniatura quebrada, "Não foi possível gerar o PDF."). Testado ao vivo no aparelho do usuário via `flutter run` + `adb logcat`, o que permitiu achar a causa raiz real pela primeira vez (sessões anteriores só tinham corrigido a causa de um sintoma parecido, mas diferente — o travamento do `uri_to_file`). Na sequência, o usuário enviou um documento de referência (zip com um mockup HTML/CSS de replanejamento visual completo do app, gerado externamente) e pediu para implementar as telas mais simples primeiro.

### Corrigido
- **Bug real do Scanner**: `ContentUriReader.readBytes` não tratava URIs `file://` (só `content://` e caminho puro) — em alguns aparelhos/versões do Play Services o scanner devolve `file:///data/.../pagina.jpg`, que caía no ramo errado e virava `PathNotFoundException` toda vez. Corrigido convertendo `file://` para caminho real via `Uri.parse(...).toFilePath()`. Coberto por 4 testes novos em [test/content_uri_reader_test.dart](../test/content_uri_reader_test.dart) — ver [07-engenharia.md](07-engenharia.md#riscos) para o relato completo da investigação.
- **`ScannerController.escanearDocumento()` usava `paginas.assignAll(...)` em vez de `addAll(...)`**: cada novo scan **substituía** a lista de páginas em vez de acrescentar, perdendo páginas já escaneadas. Bug real e independente do de cima, encontrado na mesma investigação.
- **Ambiente da máquina**: disco C: estava com 352 MB livres porque `GRADLE_USER_HOME` (configurado numa sessão anterior para apontar pro drive E:) não estava sendo herdado pelo shell usado para os builds, então o cache do Gradle (~1,9 GB) voltou a crescer em `C:\Users\<usuário>\.gradle`; um build interrompido por falta de memória corrompeu esse cache. Cache duplicado removido, `GRADLE_USER_HOME` exportado explicitamente nos comandos de build desta sessão em diante.

### Adicionado — replanejamento visual (primeira metade: telas simples)
A partir de `especificacao/replanejamento/` (documento de referência recebido do usuário, não versionado no repo). Decisões tomadas com o usuário antes de começar: adotar a paleta azul-acinzentado do próprio documento (em vez de manter o ciano da logo, por causa da crítica de contraste), reativar o acesso a Meus Arquivos via "Recentes" (não um botão dedicado), e implementar telas simples primeiro (Início/Scanner/Meus Arquivos/progresso/estados vazios) — deixando o editor de texto rico e o Editor de PDF para depois.

- **Nova paleta** ([custom_colors.dart](../lib/src/config/custom_colors.dart)): tokens claros/escuros exatos do documento (fundo, superfície, texto, divisor, destaque, neutros, raios de borda), substituindo o ciano fixo usado antes.
- **`AppTheme` reescrito** ([app_theme.dart](../lib/src/config/app_theme.dart)) sem `ColorScheme.fromSeed` — monta o `ColorScheme` manualmente a partir da nova paleta, define `textTheme` (Barlow Condensed/Barlow via novo pacote `google_fonts`), `cardTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `dialogTheme`, `inputDecorationTheme`.
- **`CustomAppBar` reescrito**: fundo neutro com linha divisória (não mais faixa colorida cheia), título à esquerda, `trailing` opcional, e o bug histórico do `golBack` corrigido (agora realmente controla se o botão de voltar aparece).
- **Tela Início redesenhada** ([select_PDF_type_view.dart](../lib/src/pages/select_PDF_type/view/select_PDF_type_view.dart)): cabeçalho próprio (título + busca + tema), card primário "Escanear documento", grade Galeria/Texto, e seção **"Recentes"** (últimos 3 PDFs com "N pág · tamanho · data" + "Ver todos" → Meus Arquivos). `SelectPdfTypeContoller` ganhou `recentes`/`carregarRecentes()`.
- **Scanner redesenhado** ([scanner_view.dart](../lib/src/pages/scanner/view/scanner_view.dart)): contagem de páginas na barra, grade com miniatura numerada + item tracejado "Adicionar" (`DottedBorderBox`, `CustomPaint` próprio, sem depender de pacote externo), rodapé avisando onde o PDF vai ser salvo.
- **Meus Arquivos**: itens da lista agora mostram "N pág · tamanho · data" em vez de só a data; chips de filtro ganharam contagem ("Todos · 12", "Favoritos · 3", "<pasta> · N" — novos `totalDocumentos`/`totalFavoritos`/`contagemPasta` no `MyFilesController`); estado vazio "de verdade" (nenhum documento salvo) agora explica o que a tela faz e oferece "Escanear documento"/"Escolher da galeria" — distinto do estado "sem resultado" de um filtro/busca sem match.
- **Progresso determinado e cancelável na geração de PDF** ([loading_controller.dart](../lib/src/components/loading/controller/loading_controller.dart) + [loading.dart](../lib/src/components/loading/view/loading.dart), reescritos): diálogo com "Página N de M" + barra + porcentagem + botão Cancelar, usado por `ScannerController` e `SelectPdfTypeContoller` (ambos iteram página a página); `TextToPdfController` usa o modo indeterminado, já que `pw.MultiPage` pagina o texto internamente numa única chamada, sem progresso por página possível. Cancelar lança `GeracaoCanceladaException`, tratada com um toast neutro em vez do toast de erro genérico.
- **`PdfDocumentModel.pageCount`** (novo campo, default `0` para documentos antigos/reconciliados do disco): os 3 controllers geradores agora passam a contagem real de páginas para `registrarDocumento(...)`, usada nos metadados de Início/Meus Arquivos.
- **`lib/src/utils/` (pasta nova)**: `Formatters` — tamanho de arquivo, data relativa ("hoje HH:mm"/"ontem HH:mm"/"D mês"), formatação de metadados de documento; usado por Início e Meus Arquivos.

### Não corrigido / adiado (escopo combinado com o usuário)
- Texto→PDF (editor rico com barra de formatação e paginação A4 ao vivo) e Editor de PDF (visual) — segunda metade do replanejamento, telas R4/R4b/R6 do documento de referência.

### Validado
- `flutter analyze`: 0 erros, sem novos avisos além dos 19 pré-existentes (contagem mudou de 22 para 19 ao longo da sessão por correções incidentais de lints tocados).
- `flutter test`: smoke test + 4 novos testes de `ContentUriReader` — todos passando.
- **Testado ao vivo no aparelho do usuário** (Redmi, Android 13, MIUI) via `flutter run` + `adb logcat`: instalado, scan completou sem travar, correção do `file://` confirmada pelo próprio log (`PathNotFoundException` parou de aparecer). Redesenho visual instalado no aparelho ao final da sessão para o usuário validar visualmente (não verificável remotamente pelo assistente).

## 2026-07-23 (5) — Identidade visual: cor da logo + tema claro/escuro

Pedido do usuário: as cores do app deveriam seguir a cor da logo/ícone, e deveria existir um botão de claro/escuro no canto direito da barra superior.

### Adicionado
- **Cor de marca extraída do ícone** (`assets/icon/icon.png`, ciano `#01DEEA`, obtida por amostragem de pixel via `System.Drawing` já que o ambiente não tinha Python/PIL disponível). `CustomColors.blue` (era um azul genérico, `0xFF357be9`, sem relação com a logo) renomeado para `CustomColors.primary`/`CustomColors.brand` e atualizado em todos os 6 arquivos que o usavam (`custom_app_bar.dart`, `loading.dart`, `text_to_pdf_view.dart`, `my_files_view.dart`, `pdf_editor_view.dart`, `scanner_view.dart`) e no spinner da splash screen (antes com um azul ainda mais antigo hardcoded, `0xFF357be9`, dessincronizado do resto do app).
- Como o ciano da marca é uma cor clara, `foregroundColor`/texto branco sobre ela (app bar, botões, badge de número de página no Scanner) foi trocado para `Colors.black87` — o branco anterior (herdado da paleta azul escura antiga) tinha contraste ruim sobre o novo ciano.
- **Tema claro/escuro real**: `lib/src/config/app_theme.dart` (`AppTheme.light`/`AppTheme.dark`, ambos via `ColorScheme.fromSeed(seedColor: CustomColors.brand)`) e `lib/src/config/theme_controller.dart` (`ThemeController`, `GetxController` com `Rx<ThemeMode>`, padrão `ThemeMode.system`, persistido em Hive na nova box `app_settings`). `main.dart` inicializa e registra o controller antes do `runApp`, e passa `theme`/`darkTheme`/`themeMode` ao `GetMaterialApp` dentro de um `Obx` para reagir à troca em tempo real.
- **Botão de alternância de tema** no canto direito do `CustomAppBar` (ícone de sol/lua conforme o tema ativo), chamando `ThemeController.alternar()`.
- Os 3 cards da tela inicial (`select_PDF_type_view.dart`), antes com fundo branco fixo (`Colors.white`), agora usam `Theme.of(context).colorScheme.surface`, para não ficarem como caixas brancas destoantes sobre o fundo escuro do tema dark.

### Validado
- `flutter analyze`: 0 erros, 22 avisos pré-existentes (mesma contagem de antes).
- `flutter test`: smoke test passando (`widget_test.dart` atualizado para registrar `ThemeController` e inicializar a nova box Hive, mesmo padrão já usado para `PdfDocumentsRepository`).
- `flutter build web --release`: build de produção completa sem erros; servida estaticamente e inspecionada via console/rede do navegador — os 3 boxes Hive (`pdf_documents`, `pdf_folders`, `app_settings`) abrem sem exceção, confirmando que `ThemeController.init()` roda corretamente, e nenhum erro aparece no console.
- **Renderização visual não confirmada neste ambiente**: o Browser pane usado nesta sessão não conseguiu pintar o Flutter Web (nem em modo debug via `flutter run -d web-server`, nem no build de release servido estaticamente — em ambos os casos a `<flutter-view>` nunca ganha tamanho e nenhum `<canvas>` chega a ser criado, apesar do app inicializar e não lançar erros). Já era uma limitação conhecida deste ambiente, documentada antes desta sessão de mudanças — não é causada pelo tema novo. **O usuário precisa conferir visualmente** (rodando no celular, emulador, ou `flutter run -d chrome` numa máquina com navegador de verdade) se as cores e a troca de tema estão como esperado.

## 2026-07-23 (4) — Correção: travamento do Scanner, botão Meus Arquivos oculto, campo de texto maior

Feedback do usuário testando o app já publicado: o Scanner travava "no infinito" ao carregar a página escaneada (impedindo gerar o PDF), a categoria "Meus Arquivos" não fazia sentido para o usuário, e o campo de texto do Texto→PDF era pequeno demais para digitar confortavelmente.

### Corrigido
- **Travamento infinito no Scanner**: causa raiz era o pacote `uri_to_file`, que travava indefinidamente ao resolver URIs `content://` retornadas pelo scanner nativo em aparelhos Android reais — já sinalizado como risco em [07-engenharia.md](07-engenharia.md). Removido e substituído por um `MethodChannel` próprio (`com.dsdevsolucoes.dspdf/content_resolver`) implementado em `MainActivity.kt`, que lê os bytes via `ContentResolver.openInputStream()` nativo. No lado Dart, novo serviço `ContentUriReader` (`lib/src/services/content_uri_reader.dart`, primeira pasta `services/` do projeto) encapsula a chamada com timeout de 15s como rede de segurança. `ScannerController.gerarPDF()` e a miniatura de página em `ScannerView` (`_PaginaThumbnail`, agora com `Image.memory` em vez de `Image.file`) passaram a usar esse serviço; a miniatura também ganhou um estado de erro visível (ícone de imagem quebrada) em vez de deixar o spinner girando para sempre em caso de falha de leitura.

### Alterado
- **Botão "Meus Arquivos" comentado** (não removido) em `select_PDF_type_view.dart`, a pedido do usuário — não fazia sentido ter essa categoria separada podendo adicionar imagens direto no PDF. Rota, `MyFilesView`/`MyFilesController` e `PdfDocumentsRepository` continuam intactos e ativos: os 3 fluxos de geração de PDF (Galeria, Câmera, Texto) continuam registrando os documentos gerados no Hive normalmente, mesmo sem tela para visualizá-los (decisão explícita do usuário, mantendo o histórico salvo para uma eventual reativação futura do botão).
- **Campo de texto do corpo em Texto→PDF ampliado** para ocupar pelo menos metade da altura da tela (`SizedBox(height: MediaQuery.of(context).size.height * 0.5)`), envolvendo o `body` da tela num `SingleChildScrollView` para acomodar o campo maior. Novo parâmetro `expands` (padrão `false`) adicionado a `CustomTextField` para viabilizar isso (usa `TextFormField.expands`). Cabeçalho e rodapé não foram alterados, a pedido explícito do usuário.

### Validado
- `flutter analyze`: 0 erros, 22 avisos pré-existentes (mesma contagem de antes desta sessão).
- `flutter test`: smoke test continua passando.
- **Não validado em aparelho físico real** — a correção do Scanner elimina a causa raiz identificada (dependência de terceiros travando na leitura de `content://`), mas o teste em hardware Android real, que foi onde o problema original foi reportado, ainda precisa ser feito pelo usuário.

## 2026-07-23 (3) — Correção: erro real de upload no Play Console (targetSdk)

Primeiro envio real do `.aab` ao Play Console (teste interno) retornou 1 erro bloqueador e 2 avisos.

### Corrigido
- **Erro "nível desejado da API do app é 34... precisa ser de pelo menos 35"**: `targetSdk` fixado em 35 em `android/app/build.gradle.kts` (antes usava o padrão do Flutter, 34). A Play Store exige um `targetSdk` mínimo que sobe todo ano — esse valor deve ser revisado a cada novo envio de versão.
- `buildTypes.release` ganhou `ndk { debugSymbolLevel = "FULL" }`, tentando resolver o aviso de símbolos de depuração nativos ausentes — não eliminou o aviso (ver Riscos em [07-engenharia.md](07-engenharia.md)), mas mantido por ser inofensivo.

### Não corrigido (não é um problema do projeto)
- Aviso "não fez upload dos símbolos de depuração": comum em apps Flutter, referente aos binários pré-compilados do motor do Flutter (`libapp.so`/`libflutter.so`), não bloqueia a publicação.
- Aviso "nenhum testador especificado": configuração feita direto no Play Console (aba de testadores da faixa de teste), não no código.

## 2026-07-23 (2) — Configuração: applicationId e nome de exibição definitivos

Segundo passo do checklist de publicação: identidade do app na Play Store.

### Alterado
- `applicationId`/`namespace`: `com.dsdev.pdf.ds_pdf` → **`com.dsdevsolucoes.dspdf`** (em `android/app/build.gradle.kts`) — definitivo, não muda mais depois do primeiro envio à Play Store.
- `MainActivity.kt` movido de `android/app/src/main/kotlin/com/dsdev/pdf/ds_pdf/` para `android/app/src/main/kotlin/com/dsdevsolucoes/dspdf/`, com o `package` atualizado.
- Nome de exibição do app: `android:label` (Android, em `AndroidManifest.xml`) e `CFBundleDisplayName` (iOS, em `Info.plist`) → **"DS PDF"** (antes "ds_pdf"/"Ds Pdf").
- `pubspec.yaml`: `description` atualizada (antes era o texto padrão do `flutter create`). O campo `name: ds_pdf` (nome interno do pacote Dart, usado em todos os `import 'package:ds_pdf/...'` do projeto) **não foi alterado** — é independente do `applicationId`/nome de exibição, e renomeá-lo exigiria atualizar todos os imports do projeto sem nenhum benefício real.

### Validado
- `flutter analyze`: 0 erros, sem novos avisos.
- `flutter build appbundle --release` e `flutter build apk --release`: completam com sucesso.
- `aapt2 dump badging` no APK gerado confirma `package: name='com.dsdevsolucoes.dspdf'` e `application-label:'DS PDF'`.

## 2026-07-23 — Configuração: assinatura de release para a Play Store

Primeiro passo do checklist oficial do Flutter para publicação ([docs.flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android)): o build de release estava assinado com a chave de debug, o que a Play Store rejeita.

### Adicionado
- `android/upload-keystore.jks` — keystore de release (RSA 2048, validade ~27 anos, alias `upload`). **Não versionado** (fora do git, `android/.gitignore` já cobre `*.jks`).
- `android/key.properties` — credenciais do keystore (alias, senhas, caminho do arquivo). **Não versionado** (`android/.gitignore` já cobre `key.properties`).
- `android/app/build.gradle.kts`: lê `key.properties` (se existir) e monta `signingConfigs.release` a partir dele; `buildTypes.release` usa essa config em vez da de debug. Se `key.properties` não existir (clone novo, CI sem o arquivo), cai de volta para a assinatura de debug em vez de quebrar o build.

### Validado
- `flutter build appbundle --release` — gera `app-release.aab` (formato exigido pela Play Store).
- `flutter build apk --release` — gera `app-release.apk`; conferido com `apksigner verify --print-certs` que o certificado usado é o do `upload-keystore.jks` (SHA-256 bate), não mais o de debug.

### ⚠️ Importante — backup
`android/upload-keystore.jks` e a senha em `android/key.properties` não têm cópia em nenhum outro lugar. **Fazer backup de ambos agora** (ex.: gerenciador de senhas + um local seguro fora deste computador) — perder o keystore antes de ativar o Play App Signing no Play Console pode impedir a publicação de futuras atualizações do mesmo app.

## 2026-07-22 (2) — Correção: build Android quebrado (Windows, celular, APK)

O app não rodava no Windows, não rodava direto no celular e não gerava APK (nem debug nem release) — não era um problema do ambiente do usuário, era configuração desatualizada do projeto. Ver diagnóstico completo e todas as correções em [07-engenharia.md](07-engenharia.md#ambiente-de-build-windows--leia-antes-de-configurar-uma-máquina-nova).

### Corrigido
- `android/build.gradle.kts`: timing do fallback de `namespace` corrigido (`Cannot run Project.afterEvaluate... already evaluated`).
- `android/app/build.gradle.kts`: `minSdk` elevado de 21 para 23 (exigido pela dependência nativa do Scanner, `play-services-mlkit-document-scanner`).
- `android/gradle.properties`: heap do Gradle reduzido de 8G para 3G (evita `OutOfMemoryError`/crash do daemon); adicionado `-Djavax.net.ssl.trustStoreType=Windows-ROOT` (corrige falha de SSL ao baixar dependências); `kotlin.incremental=false` (evita crash do compilador Kotlin com `PUB_CACHE` em unidade de disco diferente do projeto).
- `windows/CMakeLists.txt`: silenciado erro de compilação do `permission_handler_windows` com MSVC recente (`_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS`) — já estava no repositório desde a sessão de fundação, mas só foi validado de fato nesta sessão.

### Específico desta máquina (não versionado)
- Pastas locais `C:\Android\build-tools\35.0.0` e `C:\Android\platforms\android-31` criadas manualmente (esta máquina não tinha internet para baixar via `sdkmanager`).
- `GRADLE_USER_HOME` (variável de ambiente do usuário) e a pasta `ds_pdf\build\` redirecionados para `E:\bild_flutter\` — o disco C: desta máquina estava com pouquíssimo espaço livre (chegou a 0 GB durante a sessão).

### Validado
- `flutter run -d windows`, `flutter build apk --debug` e `flutter build apk --release` completam com sucesso (testado, inclusive com o cache do Gradle recriado do zero).

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
