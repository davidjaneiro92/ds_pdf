import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../components/blueprint_frame.dart';
import '../../../config/onboarding_prefs.dart';
import '../../../enum/pages_routes.dart';

/// Tela de boas-vindas do primeiro uso (ver `especificacao/replanejamento/`,
/// seção 10) — uma tela só, sem carrossel, explicando as três formas de
/// criar um PDF. "Começar" marca [OnboardingPrefs.marcarVisto] e cumpre
/// também o papel de "pular" (não há botão separado para isso).
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DS PDF', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Três jeitos de criar um PDF',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    _bloco(
                      context,
                      icon: LucideIcons.scanText,
                      titulo: 'Escanear documento',
                      descricao: 'A câmera detecta as bordas e corrige a '
                          'perspectiva automaticamente.',
                    ),
                    const SizedBox(height: 16),
                    _bloco(
                      context,
                      icon: LucideIcons.images,
                      titulo: 'Galeria',
                      descricao: 'Transforme fotos já salvas no aparelho em '
                          'um PDF, uma por página.',
                    ),
                    const SizedBox(height: 16),
                    _bloco(
                      context,
                      icon: LucideIcons.fileText,
                      titulo: 'Texto',
                      descricao: 'Digite e formate o conteúdo direto no app, '
                          'com paginação automática.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await OnboardingPrefs.marcarVisto();
                    Get.offNamed(PagesRoutes.SelectPdfTypeView.path);
                  },
                  child: const Text('Começar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bloco(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String descricao,
  }) {
    final theme = Theme.of(context);
    return BlueprintFrame(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
