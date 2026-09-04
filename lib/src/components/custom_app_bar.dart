import 'package:ds_pdf/src/config/custom_colors.dart';
import 'package:ds_pdf/src/config/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Barra superior das telas internas (não a Início, que tem cabeçalho
/// próprio — ver [SelectPdfTypeView]): fundo igual ao da página (sem faixa
/// colorida — o replanejamento apontou baixo contraste na barra ciano
/// cheia), com uma linha divisória sutil embaixo, título alinhado à
/// esquerda e botão de voltar só quando há para onde voltar
/// (`Navigator.canPop`; antes aparecia sempre, inclusive onde não fazia
/// sentido). Aceita um [subtitle] opcional (usado no Editor de PDF, para
/// deixar explícito o nome do arquivo e que a edição salva como cópia) e
/// um [trailing] opcional para uma ação primária compacta.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? tela;
  final bool? golBack;
  final String? subtitle;
  final Widget? trailing;
  const CustomAppBar({
    super.key,
    this.tela,
    this.golBack,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final podeVoltar = (golBack ?? false) || Navigator.canPop(context);
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: subtitle != null ? kToolbarHeight + 14 : kToolbarHeight,
      leading: podeVoltar
          ? IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Get.back(),
            )
          : null,
      titleSpacing: podeVoltar ? 4 : 20,
      title: subtitle == null
          ? Text(tela ?? '')
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tela ?? ''),
                Text(
                  subtitle!,
                  style: CustomColors.monoTextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
      actions: [
        if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
        Obx(() => IconButton(
              icon: Icon(
                themeController.isDark ? LucideIcons.sun : LucideIcons.moon,
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
  Size get preferredSize => Size.fromHeight(
        (subtitle != null ? kToolbarHeight + 14 : kToolbarHeight) + 1,
      );
}