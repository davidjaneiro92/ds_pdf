# Arquitetura

## Stack

- **Flutter** 3.24.5 (channel stable) / **Dart** 3.5.4 / **DevTools** 2.37.3
- **GetX** (`package:get`) — gerenciamento de estado, injeção de dependência e navegação, tudo pela mesma biblioteca
- **pdf** + **printing** — geração e compartilhamento de PDF
- **image_picker** — seleção de imagens da galeria
- **flutter_doc_scanner** — scanner de documentos nativo (ML Kit no Android, VisionKit no iOS)
- **uri_to_file** — resolve URIs de conteúdo (`content://` no Android) retornadas pelo scanner para arquivos legíveis
- **permission_handler** — solicitação de permissões (câmera, fotos, armazenamento)
- **oktoast** — toasts globais
- **hive** + **hive_flutter** — persistência local (metadados dos PDFs gerados e das pastas, usados por Meus Arquivos)
- **syncfusion_flutter_pdf** — manipulação de PDFs já existentes (reordenar/excluir páginas, carimbar assinatura) preservando qualidade/texto vetorial, usada pelo Editor de PDF. **Biblioteca comercial** — ver aviso de licenciamento em [07-engenharia.md](07-engenharia.md#riscos)
- **signature** — captura de assinatura desenhada (canvas), usada pelo Editor de PDF

## Padrão de organização: feature-first com MVC leve

O projeto não usa Clean Architecture em camadas (`data/domain/presentation`). Em vez disso, cada **página/feature** ganha sua própria pasta com até três subpastas:

```
lib/src/pages/<feature>/
├── abstract/    # contrato (interface) do controller — opcional
├── controller/  # GetxController com a lógica/estado da feature
└── view/        # widgets da tela (StatelessWidget que consome o controller via Get.find)
```

Esse padrão é usado em todas as 5 features (`select_PDF_type/`, `scanner/`, `text_to_pdf/`, `my_files/`, `pdf_editor/`). Componentes menores e sem estado complexo (`custom_alert.dart`, `custom_toast.dart`, `custom_app_bar.dart`) ficam como arquivo único em `lib/src/components/`. Componentes com estado próprio (`loading/`) seguem o mesmo padrão `controller/` + `view/` das páginas.

### Models e Repositories (novo, a partir da feature Meus Arquivos)

Até a feature Meus Arquivos, o projeto não tinha nenhuma camada de dados — cada PDF era só um arquivo salvo em disco, sem metadado. Para viabilizar favoritos, pastas e renomear, foram criadas duas pastas novas, compartilhadas por todo o app (fora de `pages/`, no mesmo nível de `components/`/`config/`):

- **`lib/src/models/`** — classes de dados puras (`PdfDocumentModel`, `PdfFolderModel`), sem lógica de UI ou de persistência. Cada uma tem `toMap()`/`fromMap()` para serializar em/de Hive.
- **`lib/src/repositories/`** — `PdfDocumentsRepository`, único repositório do projeto. Encapsula as duas *boxes* do Hive (`pdf_documents`, `pdf_folders`) e expõe métodos de negócio (`registrarDocumento`, `listarDocumentos`, `renomear`, `excluir`, `alternarFavorito`, `moverParaPasta`, `criarPasta`, `renomearPasta`, `excluirPasta`) — nenhum código de UI ou GetX aqui, só regras de dados.

O repositório é registrado uma única vez em `main()` (`Get.put(pdfDocumentsRepository)`, depois de `await pdfDocumentsRepository.init()`) e é consumido por **4 controllers**: os 3 que geram PDF (`SelectPdfTypeContoller`, `ScannerController`, `TextToPdfController`, que chamam `registrarDocumento` logo após salvar o arquivo) e o `MyFilesController` (que lê/edita os dados). Não há `TypeAdapter`/`hive_generator`/`build_runner` — os models são serializados manualmente como `Map<String, dynamic>`, que o Hive aceita nativamente, para manter a dependência mínima.

## Gerenciamento de estado (GetX)

- Estado reativo via `.obs` (`RxList`, `RxBool`) e widgets `Obx(() => ...)` que se reconstroem automaticamente quando o valor observado muda. Exemplo: `ScannerController.paginas` (`RxList<String>`), consumido em `ScannerView` via `Obx`.
- Controllers estendem `GetxController` e, quando fazem sentido como contrato reutilizável, implementam uma interface abstrata (`SelectPdfTypeContollerAbstract`, `ScannerControllerAbstract`).

## Injeção de dependência

Todos os controllers usados pelo app são registrados uma única vez em `main()`, em [main.dart](../lib/main.dart), via `Get.put(...)`:

```dart
Get.put(pdfDocumentsRepository); // repositório, registrado antes dos controllers que o usam
Get.put(LoadingController());
Get.put<SelectPdfTypeContollerAbstract>(SelectPdfTypeContoller());
Get.put(ScannerController());
Get.put(TextToPdfController());
Get.put(MyFilesController());
```

Nas views, o controller é obtido com `Get.find()` — o tipo é inferido pela variável declarada, então precisa bater com o tipo usado no `Get.put` correspondente:

```dart
final SelectPdfTypeContollerAbstract controller = Get.find(); // registrado sob o tipo abstrato
final ScannerController controller = Get.find();               // registrado sob o tipo concreto
```

> Ponto de atenção: `ScannerController` foi registrado pelo tipo concreto (não pela interface `ScannerControllerAbstract`) porque a `ScannerView` precisa acessar `paginas` (uma `RxList` reativa) diretamente, e essa propriedade não faz parte do contrato abstrato. Se um dia a UI passar a depender só dos 3 métodos do contrato, dá para voltar a registrar pela interface.

### Exceção: `PdfEditorController` usa `binding` por rota, não `Get.put` em `main()`

Todos os outros controllers são singletons "eager", registrados uma única vez em `main()` e vivos durante toda a sessão do app. O `PdfEditorController` **não** segue esse padrão porque ele precisa saber *qual documento* está sendo editado — informação que só existe no momento da navegação (`Get.toNamed(PagesRoutes.pdfEditorView.path, arguments: documento)`), não no boot do app. Um singleton global não conseguiria representar "o documento atualmente em edição" de forma segura entre navegações diferentes.

Por isso, este é o único `GetPage` do projeto com `binding`:

```dart
GetPage(
  page: () => PdfEditorView(),
  name: PagesRoutes.pdfEditorView.path,
  binding: BindingsBuilder(() {
    Get.lazyPut(() => PdfEditorController(Get.arguments as PdfDocumentModel));
  }),
),
```

`Get.lazyPut` cria o controller só quando a rota é acessada, recebendo o `PdfDocumentModel` correto pelo construtor; a instância anterior não é reaproveitada em uma navegação seguinte a outro documento.

## Navegação

Rotas nomeadas via `GetPage`, definidas em [pages_routes.dart](../lib/src/enum/pages_routes.dart) (enum com o path de cada rota) e registradas em [app_pages.dart](../lib/src/pages_routes/app_pages.dart) (lista estática consumida por `GetMaterialApp.getPages`). Navegação feita com `Get.toNamed(...)`, `Get.offNamed(...)` e `Get.back()` — sem `Navigator` direto em nenhuma tela.

## Fluxo de dados

As 3 features de geração seguem o mesmo formato: **captura/seleção → montagem do PDF (`pw.Document`) → gravação em disco (nome único com timestamp) → registro no `PdfDocumentsRepository` → compartilhamento (`Printing.sharePdf`)**. O registro no repositório é o que permite que o PDF apareça depois em Meus Arquivos. Se o app for usado sem essa etapa rodar (ex.: crash entre salvar o arquivo e registrar), o PDF ainda aparece na lista, porque `PdfDocumentsRepository.listarDocumentos()` reconcilia com o disco a cada carregamento (varre `getApplicationDocumentsDirectory()` por `*.pdf` não registrados).

## Ciclo de vida

Controllers são instanciados uma única vez no boot do app (`Get.put` em `main()`) e vivem durante toda a sessão — exceto o `PdfEditorController` (ver acima), que usa `Get.lazyPut` via `binding` de rota e é recriado a cada navegação para o editor. Isso é aceitável no tamanho atual do projeto (poucos controllers, sem estado pesado), mas deve ser revisto se o número de features/controllers crescer muito (ver débito técnico em [07-engenharia.md](07-engenharia.md)).
