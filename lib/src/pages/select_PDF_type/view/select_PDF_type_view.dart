import 'package:ds_pdf/src/components/custom_app_bar.dart';
import 'package:ds_pdf/src/enum/pages_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../abstract/select_PDF_type_contoller_abstract.dart';



class SelectPdfTypeView extends StatelessWidget {
  final SelectPdfTypeContollerAbstract controller = Get.find();

  SelectPdfTypeView({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(
          golBack: true,
        ),
          body: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          controller.selecionarImagens();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 250,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                  'assets/img/image.png',
                                height: 150 ,
                              ),
                              Text("Galeria"),
                            ],
                          ),

                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(PagesRoutes.scannerView.path);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 250,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/img/camera.png',
                                height: 150 ,
                              ),
                              Text("Câmera"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(PagesRoutes.textToPdfView.path);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 250,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/img/documento.png',
                                height: 150 ,
                              ),
                              Text("Texto"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Botão "Meus Arquivos" removido da tela a pedido do
                    // usuário (não faz sentido ter essa categoria separada
                    // já que dá pra adicionar imagens direto no PDF).
                    // Mantido comentado (não excluído) para poder ser
                    // reativado facilmente no futuro; a rota, a view e o
                    // repositório continuam intactos.
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Get.toNamed(PagesRoutes.myFilesView.path);
                    //     },
                    //     child: Container(
                    //       padding: const EdgeInsets.all(8.0),
                    //       width: 250,
                    //       height: 190,
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: const Column(
                    //         children: [
                    //           Icon(
                    //             Icons.folder_outlined,
                    //             size: 150,
                    //             color: Colors.black54,
                    //           ),
                    //           Text("Meus Arquivos"),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}
