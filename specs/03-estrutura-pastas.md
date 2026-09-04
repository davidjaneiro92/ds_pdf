# Estrutura de Pastas

```
ds_pdf/
├── specs/                          # Esta documentação (SDD)
├── assets/
│   └── img/                        # Ícones e ilustrações usados nas telas (PNG)
├── lib/
│   ├── main.dart                   # Bootstrap: ErrorWidget global, DI (Get.put), GetMaterialApp
│   └── src/
│       ├── components/             # Widgets reutilizáveis, sem estado de negócio próprio de uma feature
│       │   ├── custom_alert.dart          # Diálogos de confirmação/informação
│       │   ├── custom_app_bar.dart        # AppBar padrão do app (com botão voltar)
│       │   ├── custom_error_widget.dart   # Tela de erro global (ErrorWidget.builder)
│       │   ├── custom_list_tile.dart      # ListTile genérico
│       │   ├── custom_text_field.dart     # TextFormField completo (senha, validação, foco)
│       │   ├── custom_toast.dart          # Toast global (sucesso/aviso/erro) via oktoast
│       │   ├── blueprint_frame.dart       # Moldura de linha com marcas de registro nos cantos (replanejamento 2026-08-17)
│       │   └── loading/                   # Overlay de loading global
│       │       ├── controller/loading_controller.dart  # 3 estados: progresso/sucesso/erro
│       │       └── view/loading.dart
│       ├── config/
│       │   ├── custom_colors.dart  # Paleta de cores do app + cantos retos + fonte mono (replanejamento visual — ver 08-auditoria.md)
│       │   ├── app_theme.dart      # ThemeData claro/escuro montado manualmente a partir de CustomColors (tipografia Barlow/Barlow Condensed via google_fonts)
│       │   ├── theme_controller.dart  # GetxController do tema ativo (ThemeMode), persistido em Hive (box "app_settings")
│       │   └── onboarding_prefs.dart  # Flag "onboardingSeen" (mesma box "app_settings"), lida pela Splash para decidir Boas-vindas vs. Início
│       ├── enum/
│       │   ├── pages_routes.dart          # Enum com os paths de todas as rotas nomeadas
│       │   ├── pdf_font_option.dart       # Fontes disponíveis para Texto→PDF (mapeadas para pw.Font)
│       │   └── pdf_text_align_option.dart # Alinhamentos disponíveis para Texto→PDF (mapeados para pw.TextAlign)
│       ├── models/                 # Classes de dados puras (sem UI, sem GetX)
│       │   ├── pdf_document_model.dart    # Metadado de um PDF gerado (nome, caminho, favorito, pasta)
│       │   └── pdf_folder_model.dart      # Pasta usada para organizar documentos em Meus Arquivos
│       ├── pages/                  # Uma pasta por feature/tela
│       │   ├── my_files/                   # Meus Arquivos: listar/pesquisar/organizar PDFs gerados
│       │   │   ├── abstract/my_files_controller_abstract.dart
│       │   │   ├── controller/my_files_controller.dart
│       │   │   └── view/my_files_view.dart
│       │   ├── pdf_editor/                 # Editor de PDF: reordenar/excluir páginas, assinar
│       │   │   ├── abstract/pdf_editor_controller_abstract.dart
│       │   │   ├── controller/pdf_editor_controller.dart
│       │   │   └── view/pdf_editor_view.dart
│       │   ├── pdf_reader/                 # Leitor de PDF: abrir, navegar, pesquisar dentro do arquivo
│       │   │   ├── abstract/pdf_reader_controller_abstract.dart
│       │   │   ├── controller/pdf_reader_controller.dart
│       │   │   ├── pdf_reader_launcher.dart    # Pontos de entrada do leitor (Início, Meus Arquivos, "Abrir com")
│       │   │   └── view/pdf_reader_view.dart
│       │   ├── scanner/                    # Scanner de documentos via câmera
│       │   │   ├── abstract/scanner_controller_abstract.dart
│       │   │   ├── controller/scanner_controller.dart
│       │   │   └── view/scanner_view.dart
│       │   ├── select_PDF_type/            # Tela inicial de seleção do tipo de conversão
│       │   │   ├── abstract/select_PDF_type_contoller_abstract.dart
│       │   │   ├── controller/select_PDF_type_contoller.dart
│       │   │   └── view/select_PDF_type_view.dart
│       │   ├── splash_screen/
│       │   │   └── splash_screen.dart      # Tela de abertura (piso de 600ms, decide Boas-vindas/Início)
│       │   ├── welcome/                    # Boas-vindas do primeiro uso (tela única, 3 blocos)
│       │   │   └── view/welcome_view.dart
│       │   └── text_to_pdf/                # Editor de texto rico → PDF (flutter_quill)
│       │       ├── abstract/text_to_pdf_controller_abstract.dart
│       │       ├── controller/text_to_pdf_controller.dart
│       │       └── view/
│       │           ├── text_to_pdf_view.dart          # Editor + barra de formatação
│       │           └── text_to_pdf_paginas_view.dart  # Pré-visualização por segmento (quebras manuais)
│       ├── pages_routes/
│       │   └── app_pages.dart      # Lista de GetPage consumida pelo GetMaterialApp
│       ├── repositories/
│       │   └── pdf_documents_repository.dart  # Único repositório do projeto; encapsula as boxes Hive
│       ├── services/                # Integrações com APIs nativas via platform channel (sem estado, sem GetX)
│       │   ├── content_uri_reader.dart  # Lê bytes de URIs "content://"/"file://" (Android) via ContentResolver nativo ou File
│       │   ├── incoming_pdf.dart        # PDFs que chegam de outro app ("Abrir com"), pelo mesmo canal nativo
│       │   └── pdf_file_picker.dart     # Escolha de um PDF do aparelho (file_picker) para o leitor
│       └── utils/                   # Funções puras de formatação/apoio, sem estado e sem GetX
│           └── formatters.dart      # Formata tamanho de arquivo, data relativa e metadados de documento (Início/Meus Arquivos)
├── test/
│   └── widget_test.dart            # Smoke test: app inicializa e mostra a splash screen
├── android/, ios/, linux/, macos/, web/, windows/   # Boilerplate de plataforma do `flutter create`
├── pubspec.yaml                    # Dependências e configuração do projeto
└── README.md
```

## O que cada pasta representa

- **`components/`** — qualquer widget usado por mais de uma tela, ou que encapsula um comportamento transversal (toast, loading, tratamento de erro). Não conhece regra de negócio de nenhuma feature específica.
- **`config/`** — configuração visual/global do app: paleta de cores, `ThemeData` claro/escuro e o controller que decide qual tema está ativo.
- **`enum/`** — enums compartilhados por todo o app: rotas, e as opções de fonte/alinhamento usadas pela feature Texto→PDF. Qualquer novo enum de domínio (ex.: tipo de filtro do scanner) deveria entrar aqui.
- **`models/`** — estruturas de dados puras, reutilizadas entre o repositório e as features que exibem/editam esses dados (hoje só `my_files/`, mas os 3 controllers geradores também usam `PdfDocumentModel` indiretamente via o repositório).
- **`pages/<feature>/`** — cada funcionalidade do app (Leitor de PDF, Scanner, Seleção de tipo, Splash, Texto→PDF, Meus Arquivos, Editor de PDF) é uma pasta isolada com seu próprio controller/view/abstract. Isso facilita adicionar ou remover uma feature inteira sem tocar em outras.
- **`pages_routes/`** — ponto único onde as rotas de todas as features são registradas no `GetMaterialApp`.
- **`repositories/`** — acesso a dados persistidos (Hive). Isola qualquer controller de saber como/onde os dados são guardados.
- **`services/`** — integrações com código nativo (platform channels) e com seletores do sistema, sem estado de UI/GetX. `ContentUriReader` substitui o pacote `uri_to_file` (removido — travava indefinidamente em URIs `content://` em aparelhos reais) por uma chamada direta ao `ContentResolver` do Android via `MainActivity.kt` — também trata URIs `file://` (formato que o scanner devolve nativamente em alguns aparelhos; ver CHANGELOG 2026-08-16). `IncomingPdf` usa esse mesmo canal para os PDFs que outro app manda abrir, e `PdfFilePicker` embrulha o `file_picker` para o botão "Abrir PDF".
- **`utils/`** — funções puras (sem widget, sem GetX, sem I/O além de leitura de metadado de arquivo) reaproveitadas por mais de uma tela. Hoje só `Formatters`.
- **`assets/img/`** — todos os assets de imagem do app (minúsculo, conforme declarado em `pubspec.yaml`; corrigido nesta sessão — ver [08-auditoria.md](08-auditoria.md)).
