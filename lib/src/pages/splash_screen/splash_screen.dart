import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/custom_colors.dart';
import '../../enum/pages_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(
    const Duration(seconds: 2),
    () {
      Get.offNamed(PagesRoutes.SelectPdfTypeView.path);
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/iconepdf.png',
              height: size.height < 900 && size.width < 400 ? 70 : 130,
            ),
            const SizedBox(
              height: 10,
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(CustomColors.brand),
            ),
            const Text("PDF Generator",
              style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              ),
            ),
            const Text("Convert images or text to PDF files"),
          ],
        ),
      ),
    );
  }
}
