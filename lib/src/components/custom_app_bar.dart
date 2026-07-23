import 'package:ds_pdf/src/config/custom_colors.dart';
import 'package:ds_pdf/src/config/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? tela;
  final bool? golBack;
  const CustomAppBar({super.key, this.tela, this.golBack  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return AppBar(
      automaticallyImplyLeading: false,// golBack ?? false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
           Get.back();
        },
      ),
      title: Row(
        children: [
          //Image.asset(
          //  'assets/img/logo-ok-3.png',
          //  height: 45,
          //),
          //SizedBox(width: 140),
          Expanded(
            //flex: 0,
              child: Center(child: Text(tela ?? ''))),
        ],
      ),
      actions: [
        Obx(() => IconButton(
              icon: Icon(
                themeController.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              tooltip: themeController.isDark ? 'Tema claro' : 'Tema escuro',
              onPressed: themeController.alternar,
            )),
      ],
      backgroundColor: CustomColors.primary,
      foregroundColor: Colors.black87,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}