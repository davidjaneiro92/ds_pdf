import 'package:ds_pdf/src/enum/pages_routes.dart';
import 'package:ds_pdf/src/models/pdf_document_model.dart';
import 'package:ds_pdf/src/pages/my_files/view/my_files_view.dart';
import 'package:ds_pdf/src/pages/pdf_editor/controller/pdf_editor_controller.dart';
import 'package:ds_pdf/src/pages/pdf_editor/view/pdf_editor_view.dart';
import 'package:ds_pdf/src/pages/pdf_reader/controller/pdf_reader_controller.dart';
import 'package:ds_pdf/src/pages/pdf_reader/view/pdf_reader_view.dart';
import 'package:ds_pdf/src/pages/scanner/view/scanner_view.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/view/select_PDF_type_view.dart';
import 'package:ds_pdf/src/pages/text_to_pdf/view/text_to_pdf_paginas_view.dart';
import 'package:ds_pdf/src/pages/text_to_pdf/view/text_to_pdf_view.dart';
import 'package:ds_pdf/src/pages/welcome/view/welcome_view.dart';
import 'package:get/get.dart';
import '../pages/splash_screen/splash_screen.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      page: () => SplashScreen(),
      name: PagesRoutes.splashScreen.path,
    ),
    GetPage(
      page: () => const WelcomeView(),
      name: PagesRoutes.welcomeView.path,
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
      page: () => TextToPdfPaginasView(),
      name: PagesRoutes.textToPdfPaginasView.path,
    ),
    GetPage(
      page: () => PdfReaderView(),
      name: PagesRoutes.pdfReaderView.path,
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PdfReaderController(Get.arguments as PdfReaderArgs));
      }),
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

