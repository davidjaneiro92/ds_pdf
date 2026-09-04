import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/custom_colors.dart';
import '../controller/loading_controller.dart';

/// Overlay de carregamento global (ver `especificacao/replanejamento/`,
/// seção "Feedback de sistema"): um único diálogo com três estados —
/// progresso (determinado "Página 3 de 5 · 60%" ou indeterminado),
/// sucesso (nome do arquivo + Compartilhar/Ver em Meus Arquivos) e erro
/// (causa em linguagem simples + tentar de novo).
class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoadingController>();
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();

      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: switch (controller.estado.value) {
                    LoadingEstado.progresso => _corpoProgresso(context, controller),
                    LoadingEstado.sucesso => _corpoSucesso(context, controller),
                    LoadingEstado.erro => _corpoErro(context, controller),
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _corpoProgresso(BuildContext context, LoadingController controller) {
    final theme = Theme.of(context);
    final atual = controller.progressoAtual.value;
    final total = controller.progressoTotal.value;
    final determinado = atual != null && total != null && total > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.mensagem.value,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: determinado ? atual / total : null,
            minHeight: 6,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
          ),
        ),
        if (determinado) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Página $atual de $total',
                style: CustomColors.monoTextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${(atual / total * 100).round()}%',
                style: CustomColors.monoTextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
        if (controller.cancelavel.value) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.cancelar,
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _corpoSucesso(BuildContext context, LoadingController controller) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.circlePlus, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('PDF gerado', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          controller.nomeArquivoSucesso.value,
          style: CustomColors.monoTextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.hideLoading();
                  controller.aoVerEmMeusArquivos?.call();
                },
                child: const Text('Ver em Meus Arquivos'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.hideLoading();
                  controller.aoCompartilhar?.call();
                },
                child: const Text('Compartilhar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _corpoErro(BuildContext context, LoadingController controller) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.circleAlert, color: theme.colorScheme.error),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Não foi possível gerar o PDF',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          controller.causaErro.value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: controller.hideLoading,
              child: const Text('Fechar'),
            ),
            if (controller.aoTentarNovamente != null) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  controller.hideLoading();
                  controller.aoTentarNovamente?.call();
                },
                child: const Text('Tentar de novo'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
