import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../components/blueprint_frame.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_text_field.dart';
import '../../../config/custom_colors.dart';
import '../../../enum/pages_routes.dart';
import '../../../enum/pdf_font_option.dart';
import '../controller/text_to_pdf_controller.dart';

/// Proporção da área útil de uma página A4 (210×297mm com margens de 2cm):
/// 170mm de largura por 257mm de altura. Usada para posicionar os
/// marcadores de página ao vivo dentro do editor — ver [_marcadoresDePagina].
const double _razaoAlturaPaginaA4 = 257 / 170;

/// Editor de texto rico para Texto→PDF (ver `especificacao/replanejamento/`,
/// seção 6): barra de formatação fixa em 3 faixas + área de digitação
/// (Quill) com marcadores de página + rodapé com contagem e ações.
class TextToPdfView extends StatefulWidget {
  const TextToPdfView({super.key});

  @override
  State<TextToPdfView> createState() => _TextToPdfViewState();
}

class _TextToPdfViewState extends State<TextToPdfView> {
  final TextToPdfController controller = Get.find();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Na primeira montagem o ScrollController ainda não tem clients, então
    // os marcadores de página não têm como saber a altura do conteúdo.
    // Um rebuild depois do primeiro frame resolve.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        tela: 'Texto para PDF',
        golBack: true,
        trailing: IconButton(
          icon: const Icon(LucideIcons.eye),
          tooltip: 'Ver páginas',
          onPressed: () => Get.toNamed(PagesRoutes.textToPdfPaginasView.path),
        ),
      ),
      body: Column(
        children: [
          _buildBarraFormatacao(context),
          Expanded(child: _buildAreaDeDigitacao(context)),
          _buildLinhaCabecalhoRodape(context),
          _buildRodape(context),
        ],
      ),
    );
  }

  // ── Barra de formatação ─────────────────────────────────────────────

  Widget _buildBarraFormatacao(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? CustomColors.neutral900
            : CustomColors.neutral100,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedBuilder(
        animation: controller.quillController,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _faixaFonteTamanho(context),
            const Divider(height: 1),
            _faixaRolavel(child: _faixaEstiloAlinhamento(context)),
            const Divider(height: 1),
            _faixaRolavel(child: _faixaListaPaginaHistorico(context)),
          ],
        ),
      ),
    );
  }

  /// Faixa que rola horizontalmente em telas estreitas, mas continua
  /// ocupando a largura toda quando cabe — o `IntrinsicWidth` +
  /// `minWidth` dá largura limitada ao `Row`, o que permite usar `Spacer`
  /// dentro dele (um `Spacer` num `Row` de largura ilimitada quebra o
  /// layout — ver specs/CHANGELOG.md, 2026-08-17).
  Widget _faixaRolavel({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Ordem importa: o ConstrainedBox precisa ficar POR FORA do
        // IntrinsicWidth. Ao contrário, o `minWidth` é engolido pela
        // largura já apertada que o IntrinsicWidth impõe ao filho.
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: IntrinsicWidth(child: child),
        ),
      ),
    );
  }

  Widget _faixaFonteTamanho(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(child: _seletorFonte(context)),
          const SizedBox(width: 12),
          _stepperTamanho(context),
        ],
      ),
    );
  }

  Widget _seletorFonte(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<PdfFontOption>(
              isExpanded: true,
              value: controller.fonte.value,
              icon: const Icon(LucideIcons.chevronDown, size: 16),
              style: theme.textTheme.bodyMedium,
              items: PdfFontOption.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                  .toList(),
              onChanged: (f) {
                if (f != null) controller.fonte.value = f;
              },
            ),
          )),
    );
  }

  Widget _stepperTamanho(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 112,
      height: 38,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          _botaoStepper(context, rotulo: '−', incremento: -1),
          Container(width: 1, color: theme.dividerColor),
          Expanded(
            child: Center(
              child: Obx(() => Text(
                    '${controller.tamanhoFonte.value}',
                    style: CustomColors.monoTextStyle(fontSize: 13),
                  )),
            ),
          ),
          Container(width: 1, color: theme.dividerColor),
          _botaoStepper(context, rotulo: '+', incremento: 1),
        ],
      ),
    );
  }

  Widget _botaoStepper(
    BuildContext context, {
    required String rotulo,
    required int incremento,
  }) {
    return SizedBox(
      width: 35,
      height: 38,
      child: InkWell(
        onTap: () {
          final novo = (controller.tamanhoFonte.value + incremento).clamp(8, 72);
          controller.tamanhoFonte.value = novo;
          controller.quillController
              .formatSelection(Attribute.fromKeyValue('size', '$novo'));
        },
        child: Center(child: Text(rotulo, style: const TextStyle(fontSize: 16))),
      ),
    );
  }

  Widget _faixaEstiloAlinhamento(BuildContext context) {
    final theme = Theme.of(context);
    final estilo = controller.quillController.getSelectionStyle();
    final alinhamento = estilo.attributes[Attribute.align.key]?.value;
    return Row(
      children: [
        _botaoFormato(context,
            icon: LucideIcons.bold,
            ativo: estilo.containsKey(Attribute.bold.key),
            onTap: () => _alternarAtributo(Attribute.bold)),
        _botaoFormato(context,
            icon: LucideIcons.italic,
            ativo: estilo.containsKey(Attribute.italic.key),
            onTap: () => _alternarAtributo(Attribute.italic)),
        _botaoFormato(context,
            icon: LucideIcons.underline,
            ativo: estilo.containsKey(Attribute.underline.key),
            onTap: () => _alternarAtributo(Attribute.underline)),
        _divisorVertical(theme),
        _botaoFormato(context,
            icon: LucideIcons.alignLeft,
            ativo: alinhamento == null || alinhamento == 'left',
            onTap: () => controller.quillController
                .formatSelection(Attribute.leftAlignment)),
        _botaoFormato(context,
            icon: LucideIcons.alignCenter,
            ativo: alinhamento == 'center',
            onTap: () => controller.quillController
                .formatSelection(Attribute.centerAlignment)),
        _botaoFormato(context,
            icon: LucideIcons.alignRight,
            ativo: alinhamento == 'right',
            onTap: () => controller.quillController
                .formatSelection(Attribute.rightAlignment)),
        _botaoFormato(context,
            icon: LucideIcons.alignJustify,
            ativo: alinhamento == 'justify',
            onTap: () => controller.quillController
                .formatSelection(Attribute.justifyAlignment)),
        _divisorVertical(theme),
        _botaoCor(context, estilo),
      ],
    );
  }

  /// Botão "A" com uma barra de 3px embaixo na cor ativa (ver documento de
  /// referência, seção 6.1). Abre um conjunto curado de cores, não um
  /// seletor livre.
  Widget _botaoCor(BuildContext context, Style estilo) {
    final theme = Theme.of(context);
    final hexAtual = estilo.attributes[Attribute.color.key]?.value as String?;
    final corAtual = _corDoHex(hexAtual) ?? theme.colorScheme.onSurface;
    return SizedBox(
      width: 44,
      height: 44,
      child: PopupMenuButton<String?>(
        tooltip: 'Cor do texto',
        padding: EdgeInsets.zero,
        onSelected: (hex) => controller.quillController.formatSelection(
          hex == null
              ? Attribute.clone(Attribute.color, null)
              : ColorAttribute(hex),
        ),
        itemBuilder: (context) => _coresDisponiveis.entries
            .map((e) => PopupMenuItem<String?>(
                  value: e.value,
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        color: _corDoHex(e.value) ?? theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 10),
                      Text(e.key),
                    ],
                  ),
                ))
            .toList(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Container(width: 18, height: 3, color: corAtual),
          ],
        ),
      ),
    );
  }

  static const Map<String, String?> _coresDisponiveis = {
    'Texto': null,
    'Cinza': '#5D5D60',
    'Acento': '#2C455D',
  };

  Color? _corDoHex(String? hex) {
    if (hex == null) return null;
    final limpo = hex.replaceFirst('#', '');
    final valor = int.tryParse(limpo, radix: 16);
    if (valor == null) return null;
    return Color(0xFF000000 | valor);
  }

  Widget _faixaListaPaginaHistorico(BuildContext context) {
    final theme = Theme.of(context);
    final estilo = controller.quillController.getSelectionStyle();
    final lista = estilo.attributes[Attribute.list.key]?.value;
    return Row(
      children: [
        _botaoFormato(context,
            icon: LucideIcons.list,
            ativo: lista == 'bullet',
            onTap: () => _alternarLista('bullet')),
        _botaoFormato(context,
            icon: LucideIcons.listOrdered,
            ativo: lista == 'ordered',
            onTap: () => _alternarLista('ordered')),
        _divisorVertical(theme),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton.icon(
            onPressed: controller.inserirQuebraDePagina,
            icon: const Icon(LucideIcons.separatorHorizontal, size: 18),
            label: const Text('Nova página'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              minimumSize: const Size(0, 44),
            ),
          ),
        ),
        const Spacer(),
        _botaoFormato(context,
            icon: LucideIcons.undo2,
            ativo: false,
            desabilitado: !controller.quillController.hasUndo,
            onTap: () => controller.quillController.undo()),
        _botaoFormato(context,
            icon: LucideIcons.redo2,
            ativo: false,
            desabilitado: !controller.quillController.hasRedo,
            onTap: () => controller.quillController.redo()),
      ],
    );
  }

  void _alternarAtributo(Attribute attribute) {
    final ativo = controller.quillController
        .getSelectionStyle()
        .containsKey(attribute.key);
    controller.quillController.formatSelection(
      ativo ? Attribute.clone(attribute, null) : attribute,
    );
  }

  void _alternarLista(String tipo) {
    final atual = controller.quillController
        .getSelectionStyle()
        .attributes[Attribute.list.key]
        ?.value;
    controller.quillController.formatSelection(
      atual == tipo ? Attribute.clone(Attribute.list, null) : ListAttribute(tipo),
    );
  }

  Widget _divisorVertical(ThemeData theme) => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: theme.dividerColor,
      );

  Widget _botaoFormato(
    BuildContext context, {
    required IconData icon,
    required bool ativo,
    required VoidCallback? onTap,
    bool desabilitado = false,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: ativo ? theme.colorScheme.primary : Colors.transparent,
        child: InkWell(
          onTap: desabilitado ? null : onTap,
          child: Icon(
            icon,
            size: 20,
            color: desabilitado
                ? theme.colorScheme.onSurface.withOpacity(0.4)
                : (ativo
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  // ── Área de digitação ───────────────────────────────────────────────

  Widget _buildAreaDeDigitacao(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: BlueprintFrame(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
                child: _rotuloPagina(context, 1),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final alturaPagina =
                      constraints.maxWidth * _razaoAlturaPaginaA4;
                  return Stack(
                    children: [
                      QuillEditor(
                        focusNode: _focusNode,
                        scrollController: _scrollController,
                        configurations: QuillEditorConfigurations(
                          controller: controller.quillController,
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 34),
                          placeholder: 'Digite o texto do documento…',
                          embedBuilders: [_QuebraDePaginaEmbedBuilder()],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [_scrollController, controller.quillController]),
                        builder: (context, _) => _marcadoresDePagina(
                          context,
                          alturaPagina,
                          constraints.maxHeight,
                        ),
                      ),
                      Positioned(
                        left: 1,
                        right: 1,
                        bottom: 1,
                        child: IgnorePointer(child: _esmaecerRodape(context)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Marcadores de página desenhados **por cima** do editor, na posição
  /// onde o conteúdo transborda de uma página A4 para a próxima. É uma
  /// estimativa por altura de conteúdo (não a paginação exata que o
  /// `flutter_quill_to_pdf` calcula ao gerar o PDF), mas serve ao propósito
  /// do documento de referência: avisar o usuário, enquanto digita, de que
  /// o texto passou para a página seguinte. Desenhar como overlay (em vez
  /// de inserir no documento) evita qualquer risco de mexer no cursor/na
  /// seleção a cada tecla digitada. Quebras de página **manuais** (botão
  /// "Nova página") são exatas e aparecem como embed no próprio texto.
  Widget _marcadoresDePagina(
    BuildContext context,
    double alturaPagina,
    double alturaViewport,
  ) {
    if (!_scrollController.hasClients || alturaPagina <= 0) {
      return const SizedBox.shrink();
    }
    // `hasClients` só garante que existe uma ScrollPosition — no primeiro
    // frame ela ainda não foi medida, e ler `offset`/`maxScrollExtent`
    // nesse estado lança "Null check operator used on a null value".
    final position = _scrollController.position;
    if (!position.hasPixels || !position.hasContentDimensions) {
      return const SizedBox.shrink();
    }
    final offset = position.pixels;
    final alturaConteudo = position.maxScrollExtent + alturaViewport;

    final marcadores = <Widget>[];
    for (var i = 1; i * alturaPagina < alturaConteudo; i++) {
      final y = i * alturaPagina - offset;
      if (y < -80 || y > alturaViewport + 80) continue;
      marcadores.add(Positioned(
        left: 14,
        right: 14,
        top: y,
        child: IgnorePointer(child: _marcadorFimDePagina(context, i)),
      ));
    }
    return Stack(children: marcadores);
  }

  /// A régua é fina e as etiquetas são pequenas e opacas de propósito:
  /// como o marcador é desenhado por cima do texto (não empurra o conteúdo
  /// para baixo), qualquer coisa maior tamparia linhas inteiras e deixaria
  /// o texto ilegível na altura da quebra.
  Widget _marcadorFimDePagina(BuildContext context, int numeroDaPagina) {
    final theme = Theme.of(context);
    final fundo = theme.scaffoldBackgroundColor;
    final acento = _corAcentoTexto(theme);

    Widget etiqueta(String texto, Color cor) => Container(
          color: fundo,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Text(
            texto,
            style: CustomColors.monoTextStyle(fontSize: 8, color: cor)
                .copyWith(letterSpacing: 1),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: acento.withOpacity(0.5))),
            etiqueta('FIM DA PÁGINA $numeroDaPagina', acento),
          ],
        ),
        etiqueta(
          'PÁGINA ${numeroDaPagina + 1} · A4',
          theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _rotuloPagina(BuildContext context, int numero) {
    final theme = Theme.of(context);
    return Text(
      'PÁGINA $numero · A4',
      style: CustomColors.monoTextStyle(
        fontSize: 10,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ).copyWith(letterSpacing: 1),
    );
  }

  /// Cor de acento para texto de tamanho de parágrafo — o acento puro tem
  /// contraste ~3:1, insuficiente para texto pequeno (ver documento de
  /// referência, seção 1).
  Color _corAcentoTexto(ThemeData theme) => theme.brightness == Brightness.dark
      ? CustomColors.accentDarkStrong
      : CustomColors.accentLightStrong;

  /// Máscara de gradiente de 34px na base do card: sinaliza que há mais
  /// conteúdo abaixo em vez de cortar o texto no meio da linha.
  Widget _esmaecerRodape(BuildContext context) {
    final fundo = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      height: 34,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fundo.withOpacity(0), fundo],
        ),
      ),
    );
  }

  // ── Cabeçalho e rodapé (folha inferior) ─────────────────────────────

  Widget _buildLinhaCabecalhoRodape(BuildContext context) {
    final theme = Theme.of(context);
    final ativos = controller.cabecalhoController.text.isNotEmpty ||
        controller.rodapeController.text.isNotEmpty;
    return InkWell(
      onTap: () => _abrirFolhaCabecalhoRodape(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.wrapText, size: 18),
            const SizedBox(width: 10),
            const Expanded(child: Text('Cabeçalho e rodapé')),
            Text(
              ativos ? 'Ativos' : 'Desativados',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight, size: 18),
          ],
        ),
      ),
    );
  }

  void _abrirFolhaCabecalhoRodape(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cabeçalho e rodapé',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Cabeçalho (opcional)',
              controller: controller.cabecalhoController,
              maxLength: 80,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Rodapé (opcional)',
              controller: controller.rodapeController,
              maxLength: 80,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  // ── Rodapé ──────────────────────────────────────────────────────────

  Widget _buildRodape(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final paginas = controller.paginaCountEstimado.value;
              return Text(
                '$paginas ${paginas == 1 ? 'página' : 'páginas'}\n'
                'A4 · ${controller.palavraCount.value} palavras',
                style: CustomColors.monoTextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          // Os dois botões são `Flexible` (fit loose): ficam na largura
          // natural quando cabe e encolhem — com o rótulo em uma linha só,
          // reticências se precisar — quando não cabe. Sem isso o rodapé
          // estoura em tela estreita combinada com fonte grande do sistema.
          Flexible(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () =>
                    Get.toNamed(PagesRoutes.textToPdfPaginasView.path),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                child: const Text(
                  'Ver páginas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botão primário é o único objeto sólido da tela e leva as marcas
          // de registro, conforme o documento de referência (seção 1).
          Flexible(
            child: BlueprintFrame(
              borderColor: theme.colorScheme.onPrimary.withOpacity(0.4),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => controller.gerarPDF(),
                  style:
                      ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                  child: const Text(
                    'Gerar PDF',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quebra de página **manual** (botão "Nova página"): régua com rótulo,
/// dentro do próprio fluxo do texto. Diferente dos marcadores automáticos
/// (ver `_marcadoresDePagina`), esta é exata — força início de página nova
/// no PDF gerado.
class _QuebraDePaginaEmbedBuilder extends EmbedBuilder {
  @override
  String get key => tipoEmbedQuebraDePagina;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final theme = Theme.of(context);
    final corRotulo = theme.brightness == Brightness.dark
        ? CustomColors.accentDarkStrong
        : CustomColors.accentLightStrong;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: theme.dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'NOVA PÁGINA',
              style: CustomColors.monoTextStyle(fontSize: 9, color: corRotulo)
                  .copyWith(letterSpacing: 1),
            ),
          ),
          Expanded(child: Container(height: 1, color: theme.dividerColor)),
        ],
      ),
    );
  }
}
