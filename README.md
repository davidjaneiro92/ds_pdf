# DS PDF

Aplicativo Flutter para digitalização e geração de documentos em PDF: transforme fotos e páginas escaneadas com a câmera em arquivos PDF prontos para compartilhar, no estilo Adobe Scan/Microsoft Lens/CamScanner.

## Funcionalidades

- **Scanner por câmera** — captura documentos com detecção automática de bordas, correção de perspectiva e filtros (via scanner nativo do sistema), gerando PDF.
- **Foto (galeria) → PDF** — seleciona múltiplas imagens da galeria e gera um PDF.
- **Texto → PDF** — editor de texto com escolha de fonte e alinhamento, cabeçalho/rodapé opcionais, gera PDF paginado.
- **Meus Arquivos** — lista os PDFs já gerados, com pesquisa, pastas, favoritos, compartilhar, renomear e excluir.
- **Editor de PDF** — reordenar páginas, excluir páginas e carimbar uma assinatura desenhada, a partir de um documento em Meus Arquivos.
- 📋 Planejado: dark mode — ver [specs/01-visao-geral.md](specs/01-visao-geral.md).

> ⚠️ O Editor de PDF usa `syncfusion_flutter_pdf`, uma biblioteca comercial. Funciona sem chave de licença no código, mas exige que você tenha uma licença Community (gratuita, sob condições) ou Comercial da Syncfusion — ver [specs/07-engenharia.md](specs/07-engenharia.md#riscos).

## Documentação do projeto

Toda a documentação técnica e funcional (arquitetura, estrutura de pastas, componentes, regras de negócio, fluxos, engenharia, auditoria, changelog) está na pasta [`/specs`](specs/). Comece por [specs/01-visao-geral.md](specs/01-visao-geral.md).

## Como rodar

Requisitos: Flutter 3.24.5 (stable) / Dart 3.5.4.

```bash
flutter pub get
flutter run
```

### Testes e análise estática

```bash
flutter analyze
flutter test
```

## Stack

Flutter + GetX (estado, DI e navegação) + `pdf`/`printing` (geração e compartilhamento de PDF) + `flutter_doc_scanner` (scanner nativo) + `image_picker` + `hive` (persistência local de Meus Arquivos) + `syncfusion_flutter_pdf`/`signature` (Editor de PDF). Detalhes em [specs/02-arquitetura.md](specs/02-arquitetura.md).
