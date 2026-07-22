import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_app_bar.dart';
import '../../../components/custom_text_field.dart';
import '../../../config/custom_colors.dart';
import '../../../enum/pdf_font_option.dart';
import '../../../enum/pdf_text_align_option.dart';
import '../controller/text_to_pdf_controller.dart';

class TextToPdfView extends StatelessWidget {
  final TextToPdfController controller = Get.find();

  TextToPdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(tela: 'Texto para PDF', golBack: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Texto',
                controller: controller.corpoController,
                maxLines: null,
                maxLength: null,
              ),
            ),
            CustomTextField(
              label: 'Cabeçalho (opcional)',
              controller: controller.cabecalhoController,
              maxLength: 80,
            ),
            CustomTextField(
              label: 'Rodapé (opcional)',
              controller: controller.rodapeController,
              maxLength: 80,
            ),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<PdfFontOption>(
                        decoration: const InputDecoration(labelText: 'Fonte'),
                        value: controller.fonte.value,
                        items: PdfFontOption.values
                            .map((opcao) => DropdownMenuItem(
                                  value: opcao,
                                  child: Text(opcao.label),
                                ))
                            .toList(),
                        onChanged: (opcao) {
                          if (opcao != null) controller.fonte.value = opcao;
                        },
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<PdfTextAlignOption>(
                        decoration:
                            const InputDecoration(labelText: 'Alinhamento'),
                        value: controller.alinhamento.value,
                        items: PdfTextAlignOption.values
                            .map((opcao) => DropdownMenuItem(
                                  value: opcao,
                                  child: Text(opcao.label),
                                ))
                            .toList(),
                        onChanged: (opcao) {
                          if (opcao != null) {
                            controller.alinhamento.value = opcao;
                          }
                        },
                      )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => controller.gerarPDF(),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Gerar PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
