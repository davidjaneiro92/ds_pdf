import 'package:flutter/material.dart';

void customAalertQuestion({required BuildContext context,required String title,required String message,
  required Function onPressedYes, Function? onPressedNot}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          '$title',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: 500,
          child: Text(
            '$message',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:  () {
              Navigator.of(context).pop();
              onPressedYes();
            },
            child: const Text("Sim"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if(onPressedNot != null) {
                onPressedNot!();
              }
            },
            child: const Text("Não"),
          ),
        ],
      );
    },
  );
}

void customAalertInformation({required BuildContext context,required String title,required String message}) {
  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(
        title: Text(
              '$title',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
        content: Container(
          width: 500,
          child: Text(
            '$message',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:  () {
              Navigator.of(context).pop();
            },
            child: const Text("Ok"),
          ),
        ],
      );
    },
  );
}
