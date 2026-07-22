# Regras de Negócio

Regras efetivamente implementadas no código hoje. Sempre que uma nova regra for adicionada, este arquivo deve ser atualizado junto (ver fluxo obrigatório em [../README.md](../README.md)).

## Geração de PDF (comum às três features)

- Cada página de imagem vira uma página de PDF (`pw.Page` com `pw.Image` centralizada) — sem redimensionamento, compressão ou escolha de tamanho de folha (A4/Carta) ainda. O texto (feature Texto→PDF) usa `pw.MultiPage` com paginação automática em A4.
- **Nome de arquivo único por geração**: `ds_pdf_<timestamp_ms>.pdf` (foto→PDF), `ds_pdf_scan_<timestamp_ms>.pdf` (scanner→PDF) e `ds_pdf_texto_<timestamp_ms>.pdf` (texto→PDF). Antes da sessão de fundação, o nome era fixo (`gerado.pdf`), e cada novo PDF sobrescrevia o anterior — corrigido (ver [08-auditoria.md](08-auditoria.md)).
- O PDF gerado é salvo em `getApplicationDocumentsDirectory()`, **registrado no `PdfDocumentsRepository`** (para aparecer em Meus Arquivos) e imediatamente oferecido para compartilhamento via `Printing.sharePdf` — nessa ordem: salvar → registrar → compartilhar.

## Foto → PDF (`SelectPdfTypeContoller`)

1. Solicita permissão de fotos (`Permission.photos`) e armazenamento (`Permission.storage`) antes de abrir o seletor.
2. Usuário seleciona múltiplas imagens da galeria (`ImagePicker.pickMultiImage()`).
3. Se a seleção for cancelada (`null`), nada acontece.
4. Se houver imagens selecionadas, o PDF é gerado e compartilhado automaticamente — não há etapa de revisão/reordenação antes de gerar.

## Scanner → PDF (`ScannerController`)

1. Solicita permissão de câmera (`Permission.camera`) antes de abrir o scanner nativo.
2. Abre o scanner do sistema (ML Kit no Android / VisionKit no iOS) via `flutter_doc_scanner`, com limite de até 20 páginas por sessão de escaneamento (`page: 20`).
3. Detecção de borda, correção de perspectiva, corte, rotação e filtros (P&B/colorido) são feitos pela UI nativa do scanner — o app não reimplementa essa lógica.
4. As páginas escaneadas ficam em uma lista reativa (`paginas`) e são exibidas em uma grade de miniaturas antes da geração do PDF — diferente do fluxo de Foto→PDF, que gera na hora.
5. O usuário pode escanear mais páginas (acumulando na mesma lista) ou gerar o PDF com as páginas atuais.
6. Após gerar e compartilhar o PDF, a lista de páginas é limpa (`limparPaginas()`).
7. Em caso de falha ao escanear ou ao gerar o PDF, um toast de erro é mostrado (`CustomToast`, status `error`) em vez de deixar o app travado ou silenciosamente falhar.

## Texto → PDF (`TextToPdfController`)

1. O corpo do texto é obrigatório: se estiver vazio (após `trim()`), a geração é bloqueada e um toast de aviso é mostrado (`CustomToast`, status `warner`) em vez de gerar um PDF em branco.
2. Cabeçalho e rodapé são opcionais; quando preenchidos, aparecem em todas as páginas do PDF via `pw.MultiPage(header:, footer:)`.
3. Fonte (Helvetica/Times/Courier) e alinhamento (esquerda/centro/direita/justificado) são escolhidos pelo usuário antes de gerar; usam apenas as fontes base do PDF (`pw.Font`), sem exigir nenhum arquivo `.ttf` no app.
4. O texto é paginado automaticamente pelo `pw.MultiPage` — não há limite de tamanho de texto imposto pelo app.
5. Em caso de falha ao gerar o PDF, toast de erro (`CustomToast`, status `error`), mesmo padrão das outras duas features.

## Meus Arquivos (`MyFilesController` / `PdfDocumentsRepository`)

1. **Reconciliação automática**: toda vez que a lista é carregada, o repositório varre `getApplicationDocumentsDirectory()` por arquivos `*.pdf` que ainda não têm metadado salvo (ex.: PDFs gerados antes desta feature existir) e os registra automaticamente, com nome de exibição igual ao nome do arquivo, sem pasta e não-favoritos. Nenhum PDF gerado pelo app fica de fora da listagem.
2. **Renomear não renomeia o arquivo físico** — só o `displayName` guardado no Hive. O `fileName` real em disco nunca muda, evitando qualquer risco de path quebrado.
3. **Pastas são só organização (tags)**, não pastas reais no sistema de arquivos. Um documento tem no máximo uma pasta (`folderId`); mover para outra pasta ou remover de uma pasta não move nem copia o arquivo em disco.
4. **Excluir uma pasta não exclui os documentos dela** — eles voltam para "sem pasta" (filtro "Todos").
5. **Excluir um documento remove o arquivo físico e o metadado** juntos, com confirmação prévia do usuário (`customAalertQuestion`) — ação irreversível.
6. **Pesquisa** filtra por `displayName` (case-insensitive, `contains`). **Favoritos** e **pasta selecionada** são filtros combináveis com a pesquisa (todos aplicados juntos sobre a mesma lista).
7. **Compartilhar** um documento já existente lê os bytes do arquivo em `path` e usa `Printing.sharePdf`, mesmo mecanismo das 3 features de geração.

## Editor de PDF (`PdfEditorController`)

1. Aberto a partir da opção "Editar" no menu de um documento em Meus Arquivos — não é acessível pela tela inicial.
2. Ao abrir, gera uma miniatura de cada página do PDF original (via `Printing.raster`, só para pré-visualização) e monta a ordem inicial das páginas (1, 2, 3...).
3. **Reordenar** páginas (arrastar na lista) e **excluir** páginas são só mudanças de estado na tela — nada é gravado até o usuário tocar em "Salvar".
4. **Página mínima**: não é permitido excluir a última página restante (bloqueado com toast de aviso).
5. **Assinatura**: desenhada pelo usuário num canvas (pacote `signature`) e carimbada como imagem numa página escolhida (padrão: a última; o usuário pode tocar em outra página para trocar, enquanto uma assinatura estiver definida). Não é assinatura digital criptográfica (PAdES) — é um carimbo de imagem, sempre no canto inferior direito da página (sem reposicionamento arrastável nesta versão).
6. **Salvar sempre cria um arquivo novo** (`<nome_original>_editado_<timestamp>.pdf`), nunca sobrescreve o original — o PDF editado é registrado no `PdfDocumentsRepository` como um documento independente e aparece em Meus Arquivos ao lado do original.
7. A manipulação real (reordenar, excluir, carimbar) acontece nos bytes originais via `syncfusion_flutter_pdf` (`page.createTemplate()` + `graphics.drawPdfTemplate()`), preservando texto selecionável/qualidade vetorial das páginas — as miniaturas rasterizadas existem só para a pré-visualização da tela, nunca são usadas no PDF final.

## Permissões

Todas as permissões (câmera, fotos, armazenamento) são solicitadas just-in-time, imediatamente antes da ação que precisa delas — não há tela de onboarding pedindo permissões antecipadamente.
