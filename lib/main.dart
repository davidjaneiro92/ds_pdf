import 'package:ds_pdf/src/components/custom_error_widget.dart';
import 'package:ds_pdf/src/components/custom_list_view/controller/custom_item_list_view_controller.dart';
import 'package:ds_pdf/src/components/loading/controller/loading_controller.dart';
import 'package:ds_pdf/src/components/loading/view/loading.dart';
import 'package:ds_pdf/src/enum/pages_routes.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/abstract/select_PDF_type_contoller_abstract.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/controller/select_PDF_type_contoller.dart';
import 'package:ds_pdf/src/pages_routes/app_pages.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  //tratamento de Erro caso ocora erro nos widgets
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return CustomErrorWidget(
      errorMessage: kDebugMode
          ? errorDetails.summary.toString()
          : 'Ocorreu um erro inesperado. Por favor, entre em contato com o suporte.',
    );
  };

  Get.put(CustomItemListViewController());
  Get.put(LoadingController());
  Get.put<SelectPdfTypeContollerAbstract>(SelectPdfTypeContoller());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        title: 'Controle de Separação',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003A88)),
          scaffoldBackgroundColor: Colors.white.withAlpha(190),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: PagesRoutes.splashScreen.path,
        getPages: AppPages.pages,
        builder: (context, child) {


          return Stack(
            children: [
              child!, // A tela atual
              LoadingWidget(), // Loading global
            ],
          );
        },
      ),
    );
  }
}
