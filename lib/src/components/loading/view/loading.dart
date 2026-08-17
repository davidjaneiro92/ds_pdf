import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/loading_controller.dart';

/// Overlay de carregamento global (ver `especificacao/replanejamento/`,
/// tela R7): diálogo com progresso determinado ("Página 3 de 5 · 60%")
/// quando o controller informa total de páginas, indeterminado (spinner)
/// caso contrário, e um botão "Cancelar" quando a operação é cancelável.
class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoadingController>();
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();

      final theme = Theme.of(context);
      final atual = controller.progressoAtual.value;
      final total = controller.progressoTotal.value;
      final determinado = atual != null && total != null && total > 0;

      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.mensagem.value,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: determinado ? atual / total : null,
                          minHeight: 6,
                          backgroundColor:
                              theme.colorScheme.onSurface.withOpacity(0.12),
                        ),
                      ),
                      if (determinado) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Página $atual de $total',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '${(atual / total * 100).round()}%',
                              style: theme.textTheme.bodySmall,
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
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
