# Fluxos

## Splash → Seleção de tipo

```mermaid
flowchart LR
    A[App abre] --> B[SplashScreen]
    B -->|aguarda 2s| C[Get.offNamed SelectPdfTypeView]
    C --> D[Tela: Galeria / Câmera / Texto]
```

`SplashScreen` mostra o ícone do app, um `CircularProgressIndicator` e o texto "PDF Generator". Após 2 segundos (`Future.delayed`), navega com `Get.offNamed` (substitui a rota, sem permitir voltar para a splash).

## Foto (galeria) → PDF

```mermaid
flowchart TD
    A[Card Galeria] --> B[Permission.photos + Permission.storage]
    B --> C[ImagePicker.pickMultiImage]
    C -->|cancelado| Z[Nada acontece]
    C -->|imagens selecionadas| D[gerarPDF: 1 imagem por pagina]
    D --> E[Salvar em Documents com nome unico]
    E --> E2[PdfDocumentsRepository.registrarDocumento]
    E2 --> F[Printing.sharePdf]
```

Implementado em [SelectPdfTypeContoller](../lib/src/pages/select_PDF_type/controller/select_PDF_type_contoller.dart).

## Scanner (câmera) → PDF

```mermaid
flowchart TD
    A[Card Camera] --> B[Get.toNamed scannerView]
    B --> C[ScannerView: estado vazio]
    C --> D[Permission.camera]
    D --> E[Scanner nativo: ML Kit / VisionKit]
    E -->|cancelado| C
    E -->|paginas capturadas| F[Grade de miniaturas]
    F -->|Escanear mais| D
    F -->|Gerar PDF| G[Resolver URIs com uri_to_file]
    G --> H[Montar pw.Document: 1 imagem por pagina]
    H --> I[Salvar em Documents com nome unico]
    I --> I2[PdfDocumentsRepository.registrarDocumento]
    I2 --> J[Printing.sharePdf]
    J --> K[limparPaginas]
    K --> C
```

Implementado em [ScannerController](../lib/src/pages/scanner/controller/scanner_controller.dart) + [ScannerView](../lib/src/pages/scanner/view/scanner_view.dart). A detecção de bordas, correção de perspectiva, corte, rotação e filtros acontecem inteiramente dentro da UI nativa do scanner (ML Kit/VisionKit) — o app Flutter só recebe as imagens já processadas.

## Texto → PDF

```mermaid
flowchart TD
    A[Card Texto] --> B[Get.toNamed textToPdfView]
    B --> C[TextToPdfView: editor]
    C --> D[gerarPDF]
    D -->|corpo vazio| E[Toast de aviso]
    E --> C
    D -->|corpo preenchido| F[Montar pw.MultiPage: fonte + alinhamento + header/footer opcionais]
    F --> G[Salvar em Documents com nome unico]
    G --> G2[PdfDocumentsRepository.registrarDocumento]
    G2 --> H[Printing.sharePdf]
```

Implementado em [TextToPdfController](../lib/src/pages/text_to_pdf/controller/text_to_pdf_controller.dart) + [TextToPdfView](../lib/src/pages/text_to_pdf/view/text_to_pdf_view.dart). Reaproveita [CustomTextField](../lib/src/components/custom_text_field.dart) (corpo multilinha + cabeçalho/rodapé de uma linha) e os enums [PdfFontOption](../lib/src/enum/pdf_font_option.dart)/[PdfTextAlignOption](../lib/src/enum/pdf_text_align_option.dart) para mapear a escolha do usuário para `pw.Font`/`pw.TextAlign`.

## Meus Arquivos

```mermaid
flowchart TD
    A[Card Meus Arquivos] --> B[Get.toNamed myFilesView]
    B --> C[carregar]
    C --> D[Reconciliar com disco: registra PDFs orfaos]
    D --> E[Lista filtrada: pesquisa + favoritos + pasta]
    E -->|tocar no item| F[compartilhar: Printing.sharePdf]
    E -->|estrela| G[alternarFavorito]
    E -->|menu Renomear| H[renomear: so troca displayName]
    E -->|menu Mover para pasta| I[moverParaPasta]
    E -->|menu Excluir + confirmar| J[excluir: apaga arquivo e metadado]
    E -->|chip Nova pasta| K[criarPasta]
    G --> C
    H --> C
    I --> C
    J --> C
    K --> C
```

Implementado em [MyFilesController](../lib/src/pages/my_files/controller/my_files_controller.dart) + [MyFilesView](../lib/src/pages/my_files/view/my_files_view.dart), sobre o [PdfDocumentsRepository](../lib/src/repositories/pdf_documents_repository.dart). Toda ação que muda dados (renomear, excluir, favoritar, mover, criar/excluir pasta) recarrega a lista do zero (`carregar()`) em vez de tentar sincronizar o estado local manualmente — mais simples e sem risco de a UI dessincronizar do que está salvo no Hive.

## Editor de PDF

```mermaid
flowchart TD
    A[Meus Arquivos: menu Editar] --> B[Get.toNamed pdfEditorView, arguments: documento]
    B --> C[carregar: raster de cada pagina para miniatura]
    C --> D[Lista reordenavel de paginas]
    D -->|arrastar| E[reordenarPagina]
    D -->|lixeira| F[excluirPagina: bloqueia se restar 0]
    D -->|botao Assinar| G[Canvas de assinatura: signature]
    G --> H[definirAssinatura + escolher pagina]
    E --> D
    F --> D
    H --> D
    D -->|Salvar| I[Syncfusion: template de cada pagina na ordem atual]
    I --> J[Carimbar assinatura se houver: PdfBitmap]
    J --> K[Salvar como arquivo novo: nome_editado_timestamp.pdf]
    K --> L[PdfDocumentsRepository.registrarDocumento]
    L --> M[Get.back para Meus Arquivos]
    M --> N[Meus Arquivos recarrega a lista]
```

Implementado em [PdfEditorController](../lib/src/pages/pdf_editor/controller/pdf_editor_controller.dart) + [PdfEditorView](../lib/src/pages/pdf_editor/view/pdf_editor_view.dart). Único controller do projeto registrado via `binding`/`Get.lazyPut` em vez de `Get.put` em `main()` (ver [02-arquitetura.md](02-arquitetura.md)), porque precisa saber qual documento está sendo editado a cada navegação. A manipulação real do PDF usa `syncfusion_flutter_pdf` sobre os bytes originais (preserva qualidade); `Printing.raster` (já usado no app) só gera as miniaturas de pré-visualização.

## Compartilhamento

Comum a Foto→PDF, Scanner→PDF, Texto→PDF e Meus Arquivos: `Printing.sharePdf(bytes: ..., filename: ...)`, que abre a folha de compartilhamento nativa do sistema operacional (não há upload para nuvem nem envio automático por e-mail). Em Meus Arquivos, os bytes são lidos de volta do arquivo salvo (`path`) em vez de vir direto da geração do PDF. O Editor de PDF não compartilha automaticamente ao salvar — o PDF editado fica disponível em Meus Arquivos, de onde pode ser compartilhado como qualquer outro documento.
