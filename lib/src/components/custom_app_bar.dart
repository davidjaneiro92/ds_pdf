import 'package:ds_pdf/src/config/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

/// Barra superior das telas internas (não a Início, que tem cabeçalho
/// próprio — ver [SelectPdfTypeView]): fundo igual ao da página (sem faixa
/// colorida — o replanejamento apontou baixo contraste na barra ciano
/// cheia), com uma linha divisória sutil embaixo, título alinhado à
/// esquerda e botão de voltar só quando [golBack] é true (antes aparecia
/// sempre, inclusive onde não fazia sentido).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? tela;
  final bool? golBack;
  final Widget? trailing;
  const CustomAppBar({super.key, this.tela, this.golBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      leading: (golBack ?? false)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            )
          : null,
      titleSpacing: (golBack ?? false) ? 4 : 20,
      title: Text(tela ?? ''),
      actions: [
        if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
        Obx(() => IconButton(
              icon: Icon(
                themeController.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              tooltip: themeController.isDark ? 'Tema claro' : 'Tema escuro',
              onPressed: themeController.alternar,
            )),
        const SizedBox(width: 4),
      ],
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: theme.colorScheme.onSurface,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: theme.dividerColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}