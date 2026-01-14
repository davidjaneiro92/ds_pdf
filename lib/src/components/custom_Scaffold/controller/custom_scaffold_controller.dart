import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../enum/pages_routes.dart';
import '../interfaces/custom_scaffold_controller_interface.dart';

class CustomScaffoldController extends GetxController
implements CustomScaffoldControllerInterface
{

  // Ação específica para o botão Sign Out
  void handleSignOut() {
    print('Usuário saiu!');
  }

  // Ações específicas para os itens do menu
  void handleMenuAction(String item) {
    switch(item){
      case 'Entrada':
       // Get.toNamed(PagesRoutes.nfsPedidos.path);
        break;
      case 'Saida':
        //Get.toNamed(PagesRoutes.nfsPedidos.path);
        break;
    }

  }

  void PopupMenuButton(String item, BuildContext context ) {
    switch(item){
      case 'Settings':
       // showAlertLogin(context);
        break;
      case 'Sign Out':
       // Get.offNamed(PagesRoutes.login.path);
        break;
    }

  }


}