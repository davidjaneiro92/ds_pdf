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
| `uri_to_file` | ~~^1.0.0~~ | **Removido** (2026-07-23) — travava indefinidamente ao resolver URIs `content://` reais retornadas pelo scanner em aparelhos físicos, causando o app ficar "no infinito" ao carregar a página escaneada. Substituído por `ContentUriReader` (`lib/src/services/content_uri_reader.dart`), que chama `ContentResolver.openInputStream()` nativo via `MethodChannel` implementado em `MainActivity.kt`, com timeout de 15s como rede de segurança. |
| `fluttertoast` | — | **Removido** — redundante com `oktoast`, que é a lib de toast efetivamente usada pelo `CustomToast`; nenhuma referência a `fluttertoast` existia no código. |
| `flutter_lints` (dev) | ^5.0.0 (era ^6.0.0) | `flutter_lints ^6.0.0` exige Dart `^3.8.0`, incompatível com o Dart 3.5.4 do projeto. Rebaixado para a versão mais recente compatível. |
| `flutter_launcher_icons` (dev) | ^0.14.4 | **Novo** — gera o ícone nativo do app (Android/iOS) a partir de `assets/icon/icon.png`. A configuração já existia em `pubspec.yaml`, mas o pacote nunca havia sido declarado como dependência, então o ícone nunca era de fato gerado — ver [CHANGELOG.md](CHANGELOG.md). |
| `hive` | ^2.2.3 | **Novo** — persistência local dos metadados de documentos/pastas (Meus Arquivos). |
| `hive_flutter` | ^1.1.0 | **Novo** — inicialização do Hive integrada ao Flutter (`Hive.initFlutter()` em `main.dart`, usa `path_provider` internamente). |
| `syncfusion_flutter_pdf` | ^29.1.38 | **Novo** — manipulação de PDFs existentes (reordenar/excluir páginas, carimbar assinatura) no Editor de PDF, preservando qualidade/texto vetorial. **Biblioteca comercial** — ver aviso de licenciamento abaixo em Riscos. |
| `signature` | ^5.5.0 | **Novo** — captura de assinatura desenhada (canvas) no Editor de PDF. MIT, leve, sem questões de licenciamento. |

## Ambiente de build (Windows) — leia antes de configurar uma máquina nova

O app não conseguia rodar no Windows nem gerar APK (debug ou release) nesta máquina. As causas eram configuração/ambiente, não bugs no código Dart do app. Corrigido em duas frentes:

### No repositório (`android/build.gradle.kts`, `android/app/build.gradle.kts`, `android/gradle.properties`)

| Problema | Causa | Correção |
|---|---|---|
| `Cannot run Project.afterEvaluate(Action) when the project is already evaluated` | O fallback de `namespace` para plugins antigos (`uri_to_file`) registrava `afterEvaluate` sem checar se o módulo já tinha sido avaliado. | `android/build.gradle.kts`: checa `project.state.executed` antes de decidir entre aplicar direto ou via `afterEvaluate`. |
| `uses-sdk:minSdkVersion 21 cannot be smaller than version 23` | `com.google.android.gms:play-services-mlkit-document-scanner` (dependência nativa transitiva do Scanner) exige minSdk 23; o padrão do Flutter é 21. | `android/app/build.gradle.kts`: `minSdk = 23` (Android 6.0+). |
| `Gradle build daemon disappeared` / `OutOfMemoryError` | Heap do daemon configurado em 8G, mas a máquina frequentemente tem pouca RAM livre (observado ~4,8 GB livres com outros programas abertos) — insuficiente para 8G de heap Java + overhead nativo de Kotlin/R8/AAPT2, principalmente em builds `--release` (usam R8). | `android/gradle.properties`: `-Xmx3G -XX:MaxMetaspaceSize=2G`. |
| `PKIX path building failed: unable to find valid certification path` ao baixar dependências do Maven | O trust store interno do JDK (Microsoft Build of OpenJDK 17) não reconhece a cadeia de certificado usada por `dl.google.com`/`repo.maven.apache.org` nesta máquina, mesmo o Windows confiando nela (`Invoke-WebRequest` funciona normalmente). | `android/gradle.properties`: `-Djavax.net.ssl.trustStoreType=Windows-ROOT` (faz o JVM usar o mesmo trust store do Windows). |
| `this and base files have different roots` (crash do compilador Kotlin) | `PUB_CACHE` está na unidade E: nesta máquina, mas o projeto está na unidade C:. O cache incremental do Kotlin tenta calcular caminho relativo entre arquivos-fonte de plugins (em E:) e o projeto (em C:) — impossível entre unidades diferentes no Windows. | `android/gradle.properties`: `kotlin.incremental=false` (só deixa rebuilds um pouco mais lentos). |
| Aviso "Your project is configured with Android NDK ... requer versão diferente" em todo build (não bloqueava, mas confundia com erro) | `flutter.ndkVersion` (padrão do Flutter) não bate com o NDK pedido pelos plugins nativos usados no projeto. | `android/app/build.gradle.kts`: `ndkVersion = "27.0.12077973"` fixado explicitamente — só foi possível depois de corrigir o SSL acima, que permitiu o Gradle baixar essa versão do NDK. |

### Só nesta máquina, fora do repositório (não versionado — replicar manualmente em outra máquina, se necessário)

- **`C:\Android\build-tools\35.0.0`** e **`C:\Android\platforms\android-31`** foram criados manualmente (cópias de `build-tools\34.0.0` e `platforms\android-34`, com os arquivos `source.properties`/`package.xml` ajustados para declarar as versões corretas) porque esta máquina não tinha acesso à internet para baixar esses componentes via `sdkmanager` no momento da sessão, e `flutter_plugin_android_lifecycle`/`uri_to_file` exigem, respectivamente, compileSdk 35 e compileSdk 31. **Se em algum momento houver acesso à internet**, o ideal é instalar de verdade via `sdkmanager "build-tools;35.0.0"` (o `platforms;android-31` real não é estritamente necessário — só é pedido pelo `uri_to_file`, que já está sinalizado como candidato a substituição no backlog de riscos) e remover essas pastas manuais.
- **`GRADLE_USER_HOME`** definido como variável de ambiente do usuário do Windows, apontando para `E:\bild_flutter\gradle_home` — o cache do Gradle (que pode passar de 5 GB) ficava em `C:\Users\<usuário>\.gradle` por padrão, e o disco C: desta máquina tem pouquíssimo espaço livre. Isso é uma configuração de máquina, não do projeto — outra máquina com mais espaço em C: não precisa disso.
- O diretório de build do projeto (`ds_pdf\build\`) foi transformado numa **junction do NTFS** apontando para `E:\bild_flutter\build\ds_pdf`, pelo mesmo motivo de espaço em disco.

## Riscos

- **`flutter_doc_scanner` é um pacote pequeno/comunitário** (não é um pacote oficial do Google/Flutter), embora envolva as APIs nativas oficiais (ML Kit Document Scanner, VisionKit). Se ele parar de ser mantido, a alternativa é trocar por outro wrapper equivalente (`aio_scanner`, `flutter_docs_scanner`) sem reescrever a lógica de negócio do `ScannerController` (a troca ficaria isolada nesse arquivo).
- ~~**`uri_to_file`** não tem release recente (~2 anos)...~~ **Resolvido** (2026-07-23): o pacote de fato causava o problema previsto aqui — travava indefinidamente em URIs `content://` reais em aparelhos físicos (reportado pelo usuário como o app ficar "no infinito" ao carregar a página escaneada, impedindo gerar o PDF). Removido e substituído por um platform channel próprio (`ContentUriReader` + `MainActivity.kt`), exatamente a alternativa já cogitada aqui — ver [03-estrutura-pastas.md](03-estrutura-pastas.md#services). Ainda não validado em aparelho físico pelo usuário; a correção elimina a causa raiz identificada (dependência de terceiros travando) e adiciona um timeout de 15s como rede de segurança para qualquer outra falha de leitura não prevista.
- ~~Build de release Android ainda assina com a chave de debug~~ **Resolvido**: keystore de release criado (`android/upload-keystore.jks`, alias `upload`, validade de ~27 anos), referenciado via `android/key.properties` (ambos fora do git — cobertos por `android/.gitignore`). `android/app/build.gradle.kts` monta `signingConfigs.release` a partir do `key.properties` quando ele existe; se não existir (clone novo, CI), o build de release cai para a assinatura de debug em vez de falhar. Verificado com `apksigner verify --print-certs` no APK de release: SHA-256 do certificado bate com o do keystore. **Importante**: o arquivo `android/upload-keystore.jks` e a senha guardada em `android/key.properties` precisam de backup seguro fora do repositório (ex.: gerenciador de senhas) — sem eles não é possível publicar novas versões do mesmo app na Play Store.
- ~~`applicationId` ainda é o padrão gerado pelo `flutter create`~~ **Resolvido**: definido como `com.dsdevsolucoes.dspdf` (ver Backlog).
- **`targetSdk` precisa acompanhar a exigência mínima da Play Store, que sobe todo ano.** Fixado em 35 (Android 15) em `android/app/build.gradle.kts` — o padrão do Flutter 3.24.5 (34) foi **rejeitado no upload real do `.aab`** ao Play Console em 2026-07-23 ("nível desejado da API... precisa ser de pelo menos 35"). Revisar esse valor a cada novo envio de versão.
- **Aviso "não fez upload dos símbolos de depuração" no Play Console é esperado e não bloqueia a publicação.** É sobre `libapp.so`/`libflutter.so` (motor do Flutter, pré-compilado, sem símbolos de depuração embutidos) — comum em praticamente qualquer app Flutter, não uma falha de configuração deste projeto. Tentado `ndk { debugSymbolLevel = "FULL" }` em `buildTypes.release` (mantido, não atrapalha) e `flutter build appbundle --release --split-debug-info=build/symbols` (gera mapas de símbolo Dart, úteis para desofuscar stack traces com `flutter symbolize`, mas não resolve o aviso específico do Play Console sobre símbolos nativos). Sem solução conhecida no nível do projeto — é uma limitação de como o Flutter distribui seu motor.
- **Licenciamento do `syncfusion_flutter_pdf` (⚠️ ação necessária do usuário/empresa, não é algo que o código resolva)**: é uma biblioteca comercial. A partir da versão usada nesta sessão (≥18.3.35, e a instalada é 29.1.38), **não é mais necessário registrar uma chave de licença no código** — o pacote funciona tecnicamente sem isso, sem marca d'água/aviso de trial nos PDFs gerados. Porém, contratualmente, a Syncfusion exige que quem usa a biblioteca tenha uma licença: **Community** (gratuita, para indivíduos ou empresas com faturamento anual abaixo de um limite definido pela Syncfusion, mediante cadastro em syncfusion.com) ou **Comercial**. Isso não foi verificado nem contratado por mim — é uma obrigação legal do lado de quem publica o app, que só o usuário pode resolver.

## Backlog (funcionalidades futuras)

1. ~~Dark mode~~ **Resolvido** (2026-07-23): `AppTheme.light`/`AppTheme.dark` (`lib/src/config/app_theme.dart`), ambos com `ColorScheme.fromSeed(seedColor: CustomColors.brand)`; `ThemeController` (`lib/src/config/theme_controller.dart`) guarda o `ThemeMode` ativo num `Rx`, persistido em Hive (box `app_settings`), e é lido via `Obx` em torno do `GetMaterialApp` em `main.dart`. Alternado pelo botão de sol/lua no canto direito do `CustomAppBar`. Não cobre o padrão do sistema de forma reativa a mudanças em tempo real (`ThemeMode.system` funciona, mas só é reavaliado quando `alternar()` é chamado, não a cada mudança de brilho do SO) — melhoria possível futura.
2. Testes automatizados além do smoke test atual (testes de controller/repositório com mocks, ex.: `ScannerController.gerarPDF`, `PdfDocumentsRepository` com Hive em memória, `PdfEditorController.salvar` com um PDF de teste).
3. ~~Revisão do `applicationId` e do nome de exibição~~ **Resolvido**: `applicationId`/`namespace` definidos como `com.dsdevsolucoes.dspdf` (era o padrão `com.dsdev.pdf.ds_pdf` do `flutter create`); nome de exibição "DS PDF" no Android (`android:label`) e iOS (`CFBundleDisplayName`). `MainActivity.kt` movido para o novo pacote (`android/app/src/main/kotlin/com/dsdevsolucoes/dspdf/`). Confirmado com `aapt2 dump badging` no APK gerado: `package: name='com.dsdevsolucoes.dspdf'` e `application-label:'DS PDF'`. Assinatura de release já resolvida (ver Riscos acima).
4. Texto → PDF: fontes TrueType customizadas (hoje só as 3 fontes base do PDF), suporte a negrito/itálico, tamanho de fonte configurável.
5. Meus Arquivos: renomear pasta pela UI (a capacidade já existe no repositório — `renomearPasta` —, só falta expor no `MyFilesController`/`MyFilesView`), ordenação da lista (hoje é sempre por data de criação decrescente), seleção múltipla para excluir/mover vários documentos de uma vez.
6. Editor de PDF: marca d'água (descartada nesta sessão a pedido do usuário, pode voltar como melhoria opcional), reposicionamento arrastável da assinatura (hoje é sempre fixa no canto inferior direito), redimensionar a assinatura antes de carimbar.
