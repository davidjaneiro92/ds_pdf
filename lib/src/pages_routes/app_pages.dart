import 'package:ds_pdf/src/enum/pages_routes.dart';
import 'package:ds_pdf/src/pages/select_PDF_type/view/select_PDF_type_view.dart';
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

  ];
}

