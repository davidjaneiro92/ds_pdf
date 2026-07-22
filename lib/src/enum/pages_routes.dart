enum PagesRoutes {
  splashScreen('/splash_screen'),

  SelectPdfTypeView('/select_PDF_type_view'),

  scannerView('/scanner_view'),

  textToPdfView('/text_to_pdf_view'),

  myFilesView('/my_files_view'),

  pdfEditorView('/pdf_editor_view');

  final String path;
  const PagesRoutes(this.path);
}


