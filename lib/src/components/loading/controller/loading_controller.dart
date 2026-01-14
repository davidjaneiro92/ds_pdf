import 'package:get/get.dart';

class LoadingController extends GetxController {
  var isLoading = false.obs; // Variável observável para o loading

  void showLoading() {
    isLoading.value = true;
  }

  void hideLoading() {
    isLoading.value = false;
  }
}