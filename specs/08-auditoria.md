# Auditoria Técnica

Auditoria realizada no início desta sessão, antes de qualquer alteração, e ações tomadas em seguida.

## Estado encontrado

O projeto estava em estágio inicial/protótipo: 2 telas funcionais (Splash + Seleção de tipo) e **uma única funcionalidade completa de ponta a ponta** (Foto da galeria → PDF → compartilhar). Os cards de "Câmera" e "Documento" existiam apenas visualmente, sem `onTap`. Não havia pasta `/specs`, README descritivo, ou permissão de câmera configurada em nenhuma plataforma.

Uma parte significativa do código era **herdada de um projeto anterior não relacionado** (aparentemente um sistema de estoque/logística — termos como "grupo-almoxarifado", "recebimento de compra", "pedido-venda", "Entrada/Saida", nome de outra pessoa em comentário), e não usada por nenhuma tela do fluxo de PDF:

- `lib/src/components/custom_Scaffold/` (controller + view + interface) — Drawer com menu de perfil e itens "Entrada"/"Saída".
- `lib/src/components/custom_list_view/` (controller + views) — lista genérica de itens com colunas configuráveis.
- `lib/src/constants/Endpoints.dart` — endpoints REST de um sistema de faturamento/estoque.
- `lib/src/enum/http_methods.dart` — enum de métodos HTTP nunca usado (o projeto não tem client HTTP).
- Título do app em `main.dart`: `"Controle de Separação"`.

## Bugs encontrados

| Bug | Onde | Risco |
|---|---|---|
| Constraint de SDK desalinhada | `pubspec.yaml`: `sdk: ^3.10.0-290.4.beta` | O Flutter de fato instalado é 3.24.5/Dart 3.5.4 — a constraint não refletia a realidade e podia causar confusão/erros de resolução em outra máquina. |
| Case-sensitivity de assets | `assets/Img/` no disco vs. `assets/img/` referenciado em `pubspec.yaml` e no código | Funciona no Windows (case-insensitive) mas quebraria em builds Linux/Android/Web (case-sensitive). |
| `MaterialColor` inconsistente | `custom_colos.dart` (agora `custom_colors.dart`) | O mapa de tons de opacidade usava uma cor base (`0xFF003A88`) diferente da cor principal do `MaterialColor` (`0xFF357be9`) — tons 50–900 não correspondiam à cor real usada no app. |
| PDF com nome fixo | `select_PDF_type_contoller.dart` | Todo PDF gerado sobrescrevia o anterior (`gerado.pdf`) — usuário perdia o PDF gerado anteriormente sem aviso. |
| `print()` de debug esquecidos | `custom_text_field.dart`, `custom_item_list_view_controller.dart` (removido) | Poluição de log em produção. |
| Teste padrão quebrado | `test/widget_test.dart` | Testava um contador "+1" que não existe no app — `flutter test` falhava se executado. |
| Texto duplicado/mal formatado | `splash_screen.dart` | Dois `Text` consecutivos formando a frase "Convert Images or text to PDF files" + "text to PDF files". |
| Import interno de biblioteca de terceiros | `splash_screen.dart` | `import 'package:get/get_core/src/get_main.dart'` — import profundo desnecessário (path interno do pacote `get`), tudo já vinha de `package:get/get.dart`. |
| Ausência de permissão de câmera | `AndroidManifest.xml`, `Info.plist` | Bloqueava qualquer implementação de scanner por câmera. |
| Asset referenciado mas inexistente | `custom_Scaffold_view.dart` (removido) | `'assets/img/logo-ok-3.png'` não existia na pasta de assets; não se manifestava porque o componente não era usado. |

## Ações tomadas nesta sessão

1. **Versão do SDK**: `pubspec.yaml` corrigido para `sdk: '>=3.5.4 <4.0.0'`, alinhado ao Flutter 3.24.5 / Dart 3.5.4 / DevTools 2.37.3 já instalados. `flutter_lints` rebaixado de `^6.0.0` (exige Dart ^3.8.0) para `^5.0.0` (compatível).
2. **Remoção de código morto**: `custom_Scaffold/`, `custom_list_view/`, `Endpoints.dart`, `http_methods.dart` deletados; referências em `main.dart` removidas; título do app corrigido para "DS PDF".
3. **Correção de bugs**: assets renomeados (`Img` → `img`), `MaterialColor` corrigido, `print()` removidos, PDF passa a usar nome de arquivo único (timestamp) em ambas as features, `test/widget_test.dart` reescrito como smoke test funcional, texto duplicado da splash corrigido, import profundo removido, arquivo `custom_colos.dart` renomeado para `custom_colors.dart`.
4. **Scanner por câmera implementado**: permissões nativas adicionadas (Android `CAMERA`, iOS `NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription`), nova feature completa em `lib/src/pages/scanner/` usando `flutter_doc_scanner` (ML Kit/VisionKit) + `uri_to_file`, rota registrada, card "Câmera" da tela inicial ligado ao novo fluxo.
5. **`fluttertoast` removido** do `pubspec.yaml` (dependência sem uso, redundante com `oktoast`).

## Débito técnico não corrigido (decisão consciente de escopo)

Ver tabela completa em [07-engenharia.md](07-engenharia.md#débito-técnico-conhecido-não-corrigido-nesta-sessão-por-estar-fora-do-escopo-combinado). Resumo: nomes de arquivo/classe com erro de digitação em `select_PDF_type_*` (não renomeados para não gerar um diff de rename fora do escopo combinado com o usuário), parâmetro `golBack` não funcional, componentes não usados (`CustomListTile`, `CustomTextField` — ficam prontos para a futura tela de Texto→PDF), 22 avisos de lint (`info`/`warning`) em código pré-existente não tocado nesta sessão.

## Resultado da validação

- `flutter pub get`: resolve sem erros.
- `flutter analyze`: 0 erros, 22 avisos (todos pré-existentes, nenhum introduzido pelas mudanças desta sessão, listados em [07-engenharia.md](07-engenharia.md)).
- `flutter test`: smoke test passando após correção do teste (ver [CHANGELOG.md](CHANGELOG.md)).
