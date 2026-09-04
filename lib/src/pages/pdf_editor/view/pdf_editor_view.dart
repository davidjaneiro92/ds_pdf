import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signature/signature.dart';

import '../../../components/blueprint_frame.dart';
import '../../../components/custom_alert.dart';
import '../../../components/custom_app_bar.dart';
import '../controller/pdf_editor_controller.dart';

enum _ModoEditor { normal, reordenar, excluir }

/// Editor de PDF replanejado (ver `especificacao/replanejamento/`, seção 8):
/// grade de páginas em vez de lista, ferramentas numa barra inferior fixa
/// em vez de FAB + botão solto no topo. "Reordenar" e "Excluir" viram
/// modos — tocar numa página arrasta (reordenar) ou exclui com confirmação
/// (excluir); no modo normal, tocar escolhe a página que recebe a
/// assinatura, quando há uma definida.
class PdfEditorView extends StatefulWidget {
  const PdfEditorView({super.key});

  @override
  State<PdfEditorView> createState() => _PdfEditorViewState();
}

class _PdfEditorViewState extends State<PdfEditorView> {
  final PdfEditorController controller = Get.find();
  _ModoEditor _modo = _ModoEditor.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        tela: 'Editar PDF',
        golBack: true,
        subtitle: '${controller.documentoOriginal.fileName} · salva como cópia',
        trailing: SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () => controller.salvar(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Salvar'),
          ),
        ),
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
            Expanded(
              child: _modo == _ModoEditor.reordenar
                  ? _buildListaReordenavel(context)
                  : _buildGrade(context),
            ),
            _buildBarraFerramentas(context),
          ],
        );
      }),
    );
  }

  Widget _buildGrade(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: controller.ordemPaginas.length,
      itemBuilder: (context, index) {
        final indiceOriginal = controller.ordemPaginas[index];
        final assinaturaAqui = controller.assinatura.value != null &&
            controller.paginaDaAssinatura.value == index;
        final excluindo = _modo == _ModoEditor.excluir;

        return GestureDetector(
          onTap: () {
            if (excluindo) {
              _confirmarExcluir(context, index);
            } else if (controller.assinatura.value != null) {
              controller.definirPaginaDaAssinatura(index);
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: assinaturaAqui
                    ? BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      )
                    : null,
                padding: assinaturaAqui ? const EdgeInsets.all(2) : null,
                child: BlueprintFrame(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        controller.miniaturas[indiceOriginal],
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          color: Theme.of(context).colorScheme.primary,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (assinaturaAqui)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            color: Theme.of(context).colorScheme.primary,
                            child: Text(
                              'assinada',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      if (excluindo)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(LucideIcons.trash2,
                              color: Theme.of(context).colorScheme.error),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListaReordenavel(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: controller.ordemPaginas.length,
      onReorder: controller.reordenarPagina,
      itemBuilder: (context, index) {
        final indiceOriginal = controller.ordemPaginas[index];
        return ListTile(
          key: ValueKey(indiceOriginal),
          leading: SizedBox(
            width: 48,
            height: 64,
            child: Image.memory(
              controller.miniaturas[indiceOriginal],
              fit: BoxFit.cover,
            ),
          ),
          title: Text('Página ${index + 1}'),
          trailing: const Icon(LucideIcons.gripVertical),
        );
      },
    );
  }

  Widget _buildBarraFerramentas(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ferramenta(
            context,
            icon: LucideIcons.signature,
            rotulo: 'Assinar',
            ativo: controller.assinatura.value != null,
            onTap: () => _abrirDialogoAssinatura(context),
          ),
          _ferramenta(
            context,
            icon: LucideIcons.gripVertical,
            rotulo: 'Reordenar',
            ativo: _modo == _ModoEditor.reordenar,
            onTap: () => setState(() {
              _modo = _modo == _ModoEditor.reordenar
                  ? _ModoEditor.normal
                  : _ModoEditor.reordenar;
            }),
          ),
          _ferramenta(
            context,
            icon: LucideIcons.plus,
            rotulo: 'Adicionar',
            ativo: false,
            onTap: null,
          ),
          _ferramenta(
            context,
            icon: LucideIcons.trash2,
            rotulo: 'Excluir',
            ativo: _modo == _ModoEditor.excluir,
            onTap: () => setState(() {
              _modo = _modo == _ModoEditor.excluir
                  ? _ModoEditor.normal
                  : _ModoEditor.excluir;
            }),
          ),
        ],
      ),
    );
  }

  Widget _ferramenta(
    BuildContext context, {
    required IconData icon,
    required String rotulo,
    required bool ativo,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final cor = onTap == null
        ? theme.colorScheme.onSurface.withOpacity(0.35)
        : (ativo ? theme.colorScheme.primary : theme.colorScheme.onSurface);
    return SizedBox(
      width: 76,
      height: 56,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cor, size: 22),
            const SizedBox(height: 4),
            Text(rotulo, style: theme.textTheme.labelSmall?.copyWith(color: cor)),
          ],
        ),
      ),
    );
  }

  void _confirmarExcluir(BuildContext context, int index) {
    customAalertQuestion(
      context: context,
      title: 'Excluir página',
      message: 'Excluir a página ${index + 1}? Essa ação não pode ser '
          'desfeita nesta edição — para recuperar, feche sem salvar e '
          'abra o editor de novo.',
      onPressedYes: () => controller.excluirPagina(index),
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
            backgroundColor:
                Theme.of(context).colorScheme.surface,
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
