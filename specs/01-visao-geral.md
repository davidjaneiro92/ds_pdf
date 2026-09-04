# Visão Geral

## Objetivo do aplicativo

O **DS PDF** é um aplicativo Flutter para **ler**, digitalizar e gerar documentos em PDF, no estilo Adobe Scan / Microsoft Lens / CamScanner, com identidade visual própria. Desde 2026-09-04 a leitura é a função padrão: o app abre PDFs que já existem no aparelho (e se registra no sistema para aparecer em "Abrir com"), além de transformar fotos e páginas escaneadas com a câmera em arquivos PDF prontos para compartilhar.

## Problema que resolve

Elimina a necessidade de um leitor de PDF separado e de um scanner físico: o mesmo app abre e lê os PDFs do aparelho e digitaliza documentos, recibos e páginas de texto, com captura via câmera, correção automática de perspectiva e geração de PDF em poucos toques.

## Público-alvo

Usuários finais (pessoa física ou pequenos negócios) que precisam ler e digitalizar documentos avulsos no dia a dia, sem necessidade de recursos corporativos avançados (assinatura digital, OCR, nuvem).

## Funcionalidades

### Implementadas
| Funcionalidade | Status | Descrição |
|---|---|---|
| Leitor de PDF | ✅ Completo (2026-09-04) | Abre um PDF do aparelho (botão "Abrir PDF", ação primária da Início), de Meus Arquivos/Recentes, ou vindo de outro app por "Abrir com" — o app está registrado no Android para `application/pdf`. Rolagem contínua com zoom, seleção de texto, navegação por página (setas + "ir para página"), pesquisa de texto dentro do documento com contador de ocorrências, compartilhar, e "Salvar em Meus Arquivos" quando o arquivo veio de fora. Usa `syncfusion_flutter_pdfviewer` — ver a nota de versão em [07-engenharia.md](07-engenharia.md). |
| Foto (galeria) → PDF | ✅ Completo | Seleciona múltiplas imagens da galeria e gera um PDF (uma imagem por página), com compartilhamento. |
| Scanner por câmera → PDF | ✅ Completo | Usa o scanner nativo do sistema (ML Kit no Android, VisionKit no iOS) com detecção de bordas, correção de perspectiva e filtros automáticos; monta as páginas capturadas em um PDF e compartilha. |
| Texto → PDF | ✅ Completo (reescrito em 2026-08-17) | Editor de texto **rico** (`flutter_quill`): negrito/itálico/sublinhado, alinhamento, tamanho, cor curada, listas, quebra de página manual; barra de formatação própria em 3 faixas; tela "Páginas" de pré-visualização; cabeçalho/rodapé opcionais numa folha inferior; gera PDF via `flutter_quill_to_pdf` e compartilha. Contagem de páginas do rodapé é uma estimativa por caracteres (ver [07-engenharia.md](07-engenharia.md#backlog-funcionalidades-futuras), item 4). |
| Meus Arquivos | ✅ Completo (acesso reaberto em 2026-08-16 pela seção "Recentes" da Início) | Lista todos os PDFs gerados pelo app (com metadados em Hive: nº de páginas, tamanho, data), pesquisa por nome, pastas com contagem, favoritos, compartilhar, editar, renomear e excluir. Estava com o acesso escondido desde 2026-07-23 (a pedido do usuário); o replanejamento visual trouxe de volta via "Recentes" + "Ver todos" na tela inicial, e o ícone de busca da Início também abre esta tela. |
| Editor de PDF | ✅ Completo (redesenhado em 2026-08-17) | A partir de um documento em Meus Arquivos: grade de páginas, reordenar (modo dedicado), excluir (modo dedicado, com confirmação) e carimbar uma assinatura desenhada pelo usuário, tudo por uma barra de ferramentas fixa embaixo. Sem marca d'água (fora do escopo, a pedido do usuário) e sem assinatura digital criptográfica (é um carimbo de imagem). Salva sempre como um PDF novo, sem sobrescrever o original — a `CustomAppBar` agora deixa isso explícito no subtítulo. |
| Identidade visual + tema claro/escuro | ✅ Completo (segunda metade do replanejamento em 2026-08-17) | Paleta azul-acinzentado (`CustomColors`), tipografia Barlow Condensed/Barlow + fonte monoespaçada para metadados, cantos retos em tudo (`BorderRadius.zero`), ícones de traço fino (`lucide_icons_flutter`), molduras com marcas de registro (`BlueprintFrame`) em cards/figuras/miniaturas em todo o app. Botão de alternância claro/escuro no canto direito, preferência persistida em Hive. |
| Feedback de sistema (progresso/sucesso/erro) | ✅ Completo (2026-08-17) | `LoadingController`/`LoadingWidget` agora têm 3 estados num único diálogo: progresso (já existia), sucesso (nome do arquivo + Compartilhar/Ver em Meus Arquivos) e erro (causa em linguagem simples + tentar de novo) — substituem os toasts genéricos de sucesso/erro nos 3 fluxos de geração de PDF. |
| Boas-vindas no primeiro uso | ✅ Completo (2026-08-17) | Splash traduzida para PT-BR, sem atraso fixo de 2s (só um piso de 600ms); primeira execução mostra uma tela única explicando as 3 formas de criar PDF antes da Início, controlada por uma flag em Hive (`OnboardingPrefs`). |

## Roadmap resumido

1. **Fundação** (sessão 1) — organização do código, correção de versão de SDK, remoção de código morto herdado de outro projeto, Scanner por câmera.
2. **Sessão 2** (concluída) — Texto → PDF (editor com fontes, alinhamento, cabeçalho/rodapé).
3. **Sessão 3** (concluída) — Meus Arquivos (listagem, pesquisa, pastas, favoritos, renomear, excluir), com a primeira camada de persistência do projeto (Hive) e os primeiros `models`/`repositories`.
4. **Sessão 4** (concluída) — Editor de PDF (reordenar/excluir páginas, assinatura), usando `syncfusion_flutter_pdf` para preservar a qualidade das páginas originais — ver aviso de licenciamento em [07-engenharia.md](07-engenharia.md#riscos).
5. **Sessão 5** (concluída, 2026-07-23) — correção do travamento do Scanner, botão Meus Arquivos oculto, campo de texto maior em Texto→PDF, identidade visual seguindo a cor da logo e tema claro/escuro.
6. **Sessão 6** (concluída, 2026-08-16) — correção do bug real do Scanner (URIs `file://` não tratadas — ver [07-engenharia.md](07-engenharia.md)) e primeira metade do replanejamento visual a partir de um documento de referência enviado pelo usuário: nova paleta, tela Início (Criar PDF + Recentes), Scanner (contagem/grade/destino), Meus Arquivos (metadados/contagens), progresso determinado e cancelável na geração de PDF, estado vazio explicativo em Meus Arquivos.
7. **Sessão 7** (concluída, 2026-08-17) — segunda metade do replanejamento visual: fundação (cantos retos, `BlueprintFrame`, ícones Lucide, fonte mono), feedback de sistema (sucesso/erro), Editor de PDF redesenhado (grade + barra inferior), Texto→PDF reescrito como editor de texto rico (`flutter_quill`) com tela "Páginas", Splash em PT-BR + boas-vindas no primeiro uso. Ver [07-engenharia.md](07-engenharia.md) para as simplificações conscientes assumidas (marcadores de página automáticos como estimativa, não embeds reais) e a história de compatibilidade de versões do `flutter_quill`/`flutter_quill_to_pdf` com o Flutter 3.24.5 deste projeto.
8. **Sessão 8** (concluída, 2026-09-04) — o app virou também um **leitor** de PDF: nova tela de leitura, botão "Abrir PDF" como ação primária da Início (Escanear desceu para "Criar PDF"), toque em Recentes/Meus Arquivos abre no leitor em vez de compartilhar, e `intent-filter` no Android para o DS PDF aparecer em "Abrir com".
9. **Futuro** — testes automatizados mais amplos, marca d'água no Editor de PDF (descartada, pode voltar como melhoria opcional), reposicionamento arrastável da assinatura, miniatura real de página em Meus Arquivos, atualizar Flutter SDK para liberar versões mais novas de `flutter_quill`/`flutter_quill_to_pdf`.
