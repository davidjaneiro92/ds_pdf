import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/custom_colors.dart';
import '../controller/loading_controller.dart';


class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Get.find<LoadingController>().isLoading.value
          ? Container(
        color: Colors.black.withOpacity(0.5), // Fundo escuro
        child: Center(
          child: CircularProgressIndicator(
            color: CustomColors.blue,
          ),
        ),
      )
          : SizedBox.shrink();
    });
  }
}
