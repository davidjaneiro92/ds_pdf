import 'package:get/get.dart';

import '../view/custom_item_list_view.dart';

class CustomItemListViewController extends GetxController {
//  final HiveServicesInterface hiveServices = Get.find();
 // FormatarValoresInterface formatarValor = FormatarValores();

  var obj = [].obs;
  RxList<ColumnModel> columns = <ColumnModel>[].obs;
  RxMap<String, dynamic> item = <String, dynamic>{}.obs;

  void setObj(checkboxStates, item, count) {
    int index = obj.indexWhere((element) => element['id'] == count);
    print(index);
    if(index == -1){
      obj.add({
        'id': count,
        'checked': checkboxStates,
        'data': item,
      },);
    }else{

      obj[index] = {
        'id': count,
        'checked': checkboxStates,
        'data': item,
      };
    }

  }


  double tratarValor(String valor) {
    if (valor.contains('.')) {
      if (valor.indexOf('.') == valor.length - 2 ||
          valor.indexOf('.') == valor.length - 3) {
        return double.parse(valor);
      } else {
        return double.parse(valor.replaceAll('.', ''));
      }
    } else {
      return double.parse(valor);
    }
  }

  String TextValues(dynamic columns, dynamic item, int i) {
    switch (columns[i].typeText) {
      case "TEXT":
        if (columns[i].name.contains('.')) {
          return mapPontos(columns, i, item);

          // return item[columns[i].name.split('.')[0]][columns[i].name.split('.')[1]];
        } else {
          return item[columns[i].name]?.toString() ?? 'N/A';
        }

     // case "DATA":
     //   if (columns[i].name.contains('.')) {
     //     return _formatarData(mapPontos(columns, i, item));
     //     //return _formatarData(item[columns[i].name.split('.')[0]][columns[i].name.split('.')[1]]);
     //   } else {
     //     return _formatarData(item[columns[i].name]) ?? 'N/A';
     //   }

      case "NUMEROS":
        if (columns[i].name.contains('.')) {
          //return formatarValor.formatvalueToBrasil(mapPontos(columns, i, item));
          //return formatarValor.formatvalueToBrasil(item[columns[i].name.split('.')[0]][columns[i].name.split('.')[1]]);
        } else {
         // return formatarValor.formatvalueToBrasil(item[columns[i].name]) ??
              'N/A';
        }
    }
    return 'N/A';
  }

  //String _formatarData(dynamic valor) {
  //  try {
  //    if (valor is int) {
  //      valor = valor.toString();
  //    }
  //    //return formatarValor.formatDateTime(DateTime.parse(valor));
  //  } catch (e) {
  //    return '0000-00-00';
  //  }
  //}

  dynamic mapPontos(dynamic columns, int i, dynamic item) {
    // Divide o nome pelo ponto
    List<String> partes = columns[i].name.split('.');
    // Itera pelas partes e acessa os níveis do item
    dynamic resultado = item;
    for (String parte in partes) {
      if (resultado != null && resultado.containsKey(parte)) {
        resultado = resultado[parte];
      } else {
        return null;
      }
    }

    return resultado;
  }

}