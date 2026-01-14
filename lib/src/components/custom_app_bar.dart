import 'package:ds_pdf/src/config/custom_colos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';




class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? tela;
  final bool? golBack;
  const CustomAppBar({super.key, this.tela, this.golBack  });

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: CustomColors.blue,
      foregroundColor: Colors.white,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}