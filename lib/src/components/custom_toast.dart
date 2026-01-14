

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class CustomToast {

  void showToasts({required String messagem, required status,}){
    showToast(
      messagem,
      duration: Duration(seconds: 5),
      position: ToastPosition.bottom,
      backgroundColor: status == 'success'
          ? Colors.green
          : status == 'warner'
          ? Colors.amberAccent
          : Colors.red,
      textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
      radius: 8.0,
      dismissOtherToast: true,
    );


  }
}

abstract class status {
  static const String success = 'success';
  static const String warner = 'warner';
  static const String error = 'error';
}