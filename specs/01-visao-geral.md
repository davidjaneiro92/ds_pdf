# Visão Geral

## Objetivo do aplicativo

O **DS PDF** é um aplicativo Flutter para digitalização e geração de documentos em PDF, no estilo Adobe Scan / Microsoft Lens / CamScanner, com identidade visual própria. Permite ao usuário transformar fotos e páginas escaneadas com a câmera em arquivos PDF prontos para compartilhar.

## Problema que resolve

Elimina a necessidade de um scanner físico ou de apps de terceiros para digitalizar documentos, recibos e páginas de texto, oferecendo captura via câmera com correção automática de perspectiva e geração de PDF em poucos toques.

## Público-alvo

Usuários finais (pessoa física ou pequenos negócios) que precisam digitalizar documentos avulsos no dia a dia, sem necessidade de recursos corporativos avançados (assinatura digital, OCR, nuvem).

## Funcionalidades

### Implementadas
| Funcionalidade | Status | Descrição |
|---|---|---|
| Foto (galeria) → PDF | ✅ Completo | Seleciona múltiplas imagens da galeria e gera um PDF (uma imagem por página), com compartilhamento. |
| Scanner por câmera → PDF | ✅ Completo | Usa o scanner nativo do sistema (ML Kit no Android, VisionKit no iOS) com detecção de bordas, correção de perspectiva e filtros automáticos; monta as páginas capturadas em um PDF e compartilha. |
| Texto → PDF | ✅ Completo | Editor de texto multilinha com escolha de fonte (Helvetica/Times/Courier) e alinhamento, cabeçalho e rodapé opcionais; gera PDF paginado automaticamente e compartilha. |
| Meus Arquivos | ✅ Completo (acesso reaberto em 2026-08-16 pela seção "Recentes" da Início) | Lista todos os PDFs gerados pelo app (com metadados em Hive: nº de páginas, tamanho, data), pesquisa por nome, pastas com contagem, favoritos, compartilhar, editar, renomear e excluir. Estava com o acesso escondido desde 2026-07-23 (a pedido do usuário); o replanejamento visual trouxe de volta via "Recentes" + "Ver todos" na tela inicial, e o ícone de busca da Início também abre esta tela. |
| Editor de PDF | ✅ Completo | A partir de um documento em Meus Arquivos: reordenar páginas, excluir páginas e carimbar uma assinatura desenhada pelo usuário. Sem marca d'água (fora do escopo, a pedido do usuário) e sem assinatura digital criptográfica (é um carimbo de imagem). Salva sempre como um PDF novo, sem sobrescrever o original. Visual ainda não redesenhado pelo replanejamento de 2026-08-16 (ver roadmap). |
| Identidade visual + tema claro/escuro | ✅ Completo (paleta trocada em 2026-08-16) | Replanejamento visual completo (ver `especificacao/replanejamento/`, documento de referência enviado pelo usuário): paleta azul-acinzentado (`CustomColors`) no lugar do ciano da logo usado antes — decisão do usuário ao ver a crítica de contraste do documento —, tipografia Barlow Condensed/Barlow (`google_fonts`), barra superior sem faixa colorida cheia (baixo contraste identificado no documento). Botão de alternância claro/escuro mantido no canto direito, preferência persistida em Hive. |

## Roadmap resumido

1. **Fundação** (sessão 1) — organização do código, correção de versão de SDK, remoção de código morto herdado de outro projeto, Scanner por câmera.
2. **Sessão 2** (concluída) — Texto → PDF (editor com fontes, alinhamento, cabeçalho/rodapé).
3. **Sessão 3** (concluída) — Meus Arquivos (listagem, pesquisa, pastas, favoritos, renomear, excluir), com a primeira camada de persistência do projeto (Hive) e os primeiros `models`/`repositories`.
4. **Sessão 4** (concluída) — Editor de PDF (reordenar/excluir páginas, assinatura), usando `syncfusion_flutter_pdf` para preservar a qualidade das páginas originais — ver aviso de licenciamento em [07-engenharia.md](07-engenharia.md#riscos).
5. **Sessão 5** (concluída, 2026-07-23) — correção do travamento do Scanner, botão Meus Arquivos oculto, campo de texto maior em Texto→PDF, identidade visual seguindo a cor da logo e tema claro/escuro.
6. **Sessão 6** (concluída, 2026-08-16) — correção do bug real do Scanner (URIs `file://` não tratadas — ver [07-engenharia.md](07-engenharia.md)) e primeira metade do replanejamento visual a partir de um documento de referência enviado pelo usuário: nova paleta, tela Início (Criar PDF + Recentes), Scanner (contagem/grade/destino), Meus Arquivos (metadados/contagens), progresso determinado e cancelável na geração de PDF, estado vazio explicativo em Meus Arquivos.
7. **Futuro** — segunda metade do replanejamento visual (editor de texto rico com paginação A4 ao vivo em Texto→PDF, e redesenho do Editor de PDF), testes automatizados mais amplos, marca d'água (descartada, pode voltar como melhoria opcional), reposicionamento arrastável da assinatura.
