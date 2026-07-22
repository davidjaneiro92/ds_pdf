import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../../../components/custom_app_bar.dart';
import '../../../config/custom_colors.dart';
import '../controller/scanner_controller.dart';

class ScannerView extends StatelessWidget {
  final ScannerController controller = Get.find();

  ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(tela: 'Scanner', golBack: true),
      body: Obx(() {
        final paginas = controller.paginas;

        if (paginas.isEmpty) {
          return _buildEstadoVazio();
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: paginas.length,
                itemBuilder: (context, index) {
                  return _PaginaThumbnail(uri: paginas[index], numero: index + 1);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.escanearDocumento(),
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Escanear mais'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
          ],
        );
      }),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner_outlined, size: 96, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma página escaneada ainda',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => controller.escanearDocumento(),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Escanear documento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginaThumbnail extends StatelessWidget {
  final String uri;
  final int numero;

  const _PaginaThumbnail({required this.uri, required this.numero});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.grey.shade200),
          FutureBuilder<File>(
            future: toFile(uri),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Image.file(snapshot.data!, fit: BoxFit.cover);
            },
          ),
          Positioned(
            top: 4,
            left: 4,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: CustomColors.blue,
              child: Text(
                '$numero',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
