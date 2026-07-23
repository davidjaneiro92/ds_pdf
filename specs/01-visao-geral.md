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
| Meus Arquivos | ✅ Completo (⚠️ botão oculto na tela inicial desde 2026-07-23) | Lista todos os PDFs gerados pelo app (com metadados em Hive), pesquisa por nome, pastas, favoritos, compartilhar, renomear e excluir. Código, rota e persistência continuam intactos; só o card de acesso em `select_PDF_type_view.dart` foi comentado, a pedido do usuário (não fazia sentido ter essa categoria separada podendo adicionar imagens direto no PDF). |
| Editor de PDF | ✅ Completo | A partir de um documento em Meus Arquivos: reordenar páginas, excluir páginas e carimbar uma assinatura desenhada pelo usuário. Sem marca d'água (fora do escopo, a pedido do usuário) e sem assinatura digital criptográfica (é um carimbo de imagem). Salva sempre como um PDF novo, sem sobrescrever o original. |

### Planejadas (roadmap — ver [07-engenharia.md](07-engenharia.md))
| Funcionalidade | Status |
|---|---|
| Dark mode | 📋 Planejado, não implementado |

## Roadmap resumido

1. **Fundação** (sessão 1) — organização do código, correção de versão de SDK, remoção de código morto herdado de outro projeto, Scanner por câmera.
2. **Sessão 2** (concluída) — Texto → PDF (editor com fontes, alinhamento, cabeçalho/rodapé).
3. **Sessão 3** (concluída) — Meus Arquivos (listagem, pesquisa, pastas, favoritos, renomear, excluir), com a primeira camada de persistência do projeto (Hive) e os primeiros `models`/`repositories`.
4. **Sessão 4** (concluída) — Editor de PDF (reordenar/excluir páginas, assinatura), usando `syncfusion_flutter_pdf` para preservar a qualidade das páginas originais — ver aviso de licenciamento em [07-engenharia.md](07-engenharia.md#riscos).
5. **Futuro** — dark mode, testes automatizados mais amplos, marca d'água (descartada nesta sessão, pode voltar como melhoria opcional), reposicionamento arrastável da assinatura.
