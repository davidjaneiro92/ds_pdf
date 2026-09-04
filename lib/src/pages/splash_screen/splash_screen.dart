import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/onboarding_prefs.dart';
import '../../enum/pages_routes.dart';

/// A inicialização real (Hive, DI dos controllers) já termina em
/// `main.dart` antes de `runApp` — não há uma segunda etapa de
/// carregamento acontecendo dentro desta tela. O atraso de 600ms é só um
/// piso para a splash não piscar, não uma espera por algo ainda rodando.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Get.offNamed(
        OnboardingPrefs.visto
            ? PagesRoutes.SelectPdfTypeView.path
            : PagesRoutes.welcomeView.path,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/iconepdf.png',
              height: size.height < 900 && size.width < 400 ? 70 : 130,
            ),
            const SizedBox(height: 10),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'DS PDF',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              'Digitalize e gere PDFs',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
