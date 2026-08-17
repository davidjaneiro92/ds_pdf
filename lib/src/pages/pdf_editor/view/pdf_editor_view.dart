import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../components/custom_app_bar.dart';
import '../controller/pdf_editor_controller.dart';

class PdfEditorView extends StatelessWidget {
  final PdfEditorController controller = Get.find();

  PdfEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(tela: 'Editor de PDF', golBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.salvar(),
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar'),
      ),
      body: Obx(() {
        if (controller.carregando.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.ordemPaginas.isEmpty) {
          return const Center(child: Text('Não foi possível carregar as páginas.'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: OutlinedButton.icon(
                onPressed: () => _abrirDialogoAssinatura(context),
                icon: const Icon(Icons.draw_outlined),
                label: Text(
                  controller.assinatura.value == null
                      ? 'Assinar'
                      : 'Assinatura definida (toque numa página para escolher onde carimbar)',
                ),
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: controller.ordemPaginas.length,
                onReorder: controller.reordenarPagina,
                itemBuilder: (context, index) {
                  final indiceOriginal = controller.ordemPaginas[index];
                  final assinaturaAqui = controller.assinatura.value != null &&
                      controller.paginaDaAssinatura.value == index;

                  return Card(
                    key: ValueKey(indiceOriginal),
                    child: ListTile(
                      onTap: controller.assinatura.value == null
                          ? null
                          : () => controller.definirPaginaDaAssinatura(index),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          controller.miniaturas[indiceOriginal],
                          width: 48,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text('Página ${index + 1}'),
                      subtitle: assinaturaAqui
                          ? const Text('Assinatura será carimbada aqui')
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (assinaturaAqui)
                            const Icon(Icons.draw, color: Colors.green),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => controller.excluirPagina(index),
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _abrirDialogoAssinatura(BuildContext context) {
    final sigController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desenhe sua assinatura'),
        content: SizedBox(
          width: 300,
          height: 180,
          child: Signature(
            controller: sigController,
            width: 300,
            height: 180,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => sigController.clear(),
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (sigController.isEmpty) return;
              final bytes = await sigController.toPngBytes();
              if (bytes != null) {
                controller.definirAssinatura(bytes);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Usar assinatura'),
          ),
        ],
      ),
    );
  }
}
