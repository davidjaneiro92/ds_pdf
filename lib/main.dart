import 'package:ds_pdf/src/components/custom_error_widget.dart';
import 'package:ds_pdf/src/components/loading/controller/loading_controller.dart';
import 'package:ds_pdf/src/components/loading/view/loading.dart';
import 'package:ds_pdf/src/config/app_theme.dart';
import 'package:ds_pdf/src/config/theme_controller.dart';
import 'package:ds_pdf/src/enum/pages_routes.dart';
import 'package:ds_pdf/src/pages/my_files/controller/my_files_controller.dart';
import 'package:ds_pdf/src/pages/scanner/controller/scanner_controller.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/abstract/select_PDF_type_contoller_abstract.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/controller/select_PDF_type_contoller.dart';
import 'package:ds_pdf/src/pages/text_to_pdf/controller/text_to_pdf_controller.dart';
import 'package:ds_pdf/src/pages_routes/app_pages.dart';
import 'package:ds_pdf/src/repositories/pdf_documents_repository.dart';
import 'package:ds_pdf/src/services/incoming_pdf.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final pdfDocumentsRepository = PdfDocumentsRepository();
  await pdfDocumentsRepository.init();
  Get.put(pdfDocumentsRepository);

  final themeController = ThemeController();
  await themeController.init();
  Get.put(themeController);

  Get.put(LoadingController());
  Get.put<SelectPdfTypeContollerAbstract>(SelectPdfTypeContoller());
  Get.put(ScannerController());
  Get.put(TextToPdfController());
  Get.put(MyFilesController());

  // PDFs abertos por outro app ("Abrir com") com o DS PDF já rodando.
  IncomingPdf.iniciar();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return OKToast(
      child: Obx(() => GetMaterialApp(
            title: 'DS PDF',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.themeMode.value,
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
          )),
    );
  }
}
