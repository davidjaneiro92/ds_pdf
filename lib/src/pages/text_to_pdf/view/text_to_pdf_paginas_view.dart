import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../components/blueprint_frame.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/dotted_border_box.dart';
import '../../../config/custom_colors.dart';
import '../controller/text_to_pdf_controller.dart';

/// Pré-visualização das páginas de Texto→PDF (ver `especificacao/
/// replanejamento/`, seção 6.5) — mesmo padrão do Scanner: grade de
/// miniaturas numeradas, aqui mostrando o início do texto de cada segmento
/// (dividido pelas quebras de página manuais, ver
/// `TextToPdfController.dividirEmSegmentos`) em vez de uma imagem, já que
/// paginar o Quill pixel a pixel fica só na geração do PDF em si.
class TextToPdfPaginasView extends StatelessWidget {
  final TextToPdfController controller = Get.find();

  TextToPdfPaginasView({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentos = controller.dividirEmSegmentos();
    return Scaffold(
      appBar: CustomAppBar(
        tela: 'Páginas',
        golBack: true,
        trailing: _Tag(
            texto: segmentos.length == 1 ? '1 página' : '${segmentos.length} páginas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                // 0.68 em vez de 0.75: a célula acomoda a miniatura 3:4
                // mais a linha do número da página embaixo dela.
                childAspectRatio: 0.68,
              ),
              itemCount: segmentos.length + 1,
              itemBuilder: (context, index) {
                if (index == segmentos.length) {
                  return _TileNovaPagina(
                    onTap: () {
                      controller.inserirQuebraDePagina();
                      Get.back();
                    },
                  );
                }
                return _PaginaPreview(
                  numero: index + 1,
                  texto: controller.previewSegmento(segmentos[index]),
                );
              },
            ),
          ),
          _buildRodape(context),
        ],
      ),
    );
  }

  Widget _buildRodape(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Voltar a editar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.gerarPDF(),
              child: const Text('Gerar PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String texto;
  const _Tag({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: theme.colorScheme.surface,
      child: Text(texto, style: theme.textTheme.labelSmall),
    );
  }
}

/// Miniatura de página: figura emoldurada 3:4 com o texto real em escala
/// reduzida e o número da página **centrado embaixo** da moldura (ver
/// documento de referência, seção 6.5).
class _PaginaPreview extends StatelessWidget {
  final int numero;
  final String texto;
  const _PaginaPreview({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BlueprintFrame(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              child: Text(
                texto.trim().isEmpty ? '(página em branco)' : texto.trim(),
                overflow: TextOverflow.fade,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 5.5,
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$numero',
          textAlign: TextAlign.center,
          style: CustomColors.monoTextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

/// Célula tracejada "Nova página" — alinhada com as miniaturas (mesma
/// altura de moldura + o espaço do número embaixo, que aqui fica vazio).
class _TileNovaPagina extends StatelessWidget {
  final VoidCallback onTap;
  const _TileNovaPagina({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: DottedBorderBox(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus,
                          size: 30, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Nova\npágina',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Reserva a mesma altura do número da página das miniaturas, para
        // as molduras ficarem alinhadas entre si na grade.
        const SizedBox(height: 8),
        Text(
          '',
          textAlign: TextAlign.center,
          style: CustomColors.monoTextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
