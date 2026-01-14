//abstract class PagesRoutes {
//  static const String nfsPedidos = '/nfs_pedidos';
//}

enum PagesRoutes {
  splashScreen('/splash_screen'),

  SelectPdfTypeView('/select_PDF_type_view');


  final String path;
  const PagesRoutes(this.path);
}


