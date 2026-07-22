import 'package:ds_pdf/src/enum/pages_routes.dart';
import 'package:ds_pdf/src/models/pdf_document_model.dart';
import 'package:ds_pdf/src/pages/my_files/view/my_files_view.dart';
import 'package:ds_pdf/src/pages/pdf_editor/controller/pdf_editor_controller.dart';
import 'package:ds_pdf/src/pages/pdf_editor/view/pdf_editor_view.dart';
import 'package:ds_pdf/src/pages/scanner/view/scanner_view.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/view/select_PDF_type_view.dart';
import 'package:ds_pdf/src/pages/text_to_pdf/view/text_to_pdf_view.dart';
import 'package:get/get.dart';
import '../pages/splash_screen/splash_screen.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      page: () => SplashScreen(),
      name: PagesRoutes.splashScreen.path,
    ),
    GetPage(
      page: () => SelectPdfTypeView(),
      name: PagesRoutes.SelectPdfTypeView.path,
    ),
    GetPage(
      page: () => ScannerView(),
      name: PagesRoutes.scannerView.path,
    ),
    GetPage(
      page: () => TextToPdfView(),
      name: PagesRoutes.textToPdfView.path,
    ),
    GetPage(
      page: () => MyFilesView(),
      name: PagesRoutes.myFilesView.path,
    ),
    GetPage(
      page: () => PdfEditorView(),
      name: PagesRoutes.pdfEditorView.path,
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PdfEditorController(Get.arguments as PdfDocumentModel));
      }),
    ),
  ];
}

