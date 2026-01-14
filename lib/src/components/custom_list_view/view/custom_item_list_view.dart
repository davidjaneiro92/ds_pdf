import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/custom_item_list_view_controller.dart';

class CustomItemListView extends StatefulWidget {
  final List<ColumnModel> columns;
  final Map<String, dynamic> item;
  final Future<void> Function()? onTap;
  final CustomItemListViewController controller =
      Get.put(CustomItemListViewController());
  //final HiveServicesInterface hiveServices = Get.find();
  final int? count;

  CustomItemListView({
    super.key,
    required this.columns,
    required this.item,
    this.count,
    this.onTap,
  });

  @override
  State<CustomItemListView> createState() => _CustomItemListViewState();
}

class _CustomItemListViewState extends State<CustomItemListView> {
 // FormatarValoresInterface formatarValor = FormatarValores();
  RxMap<int, bool> checkboxStates = <int, bool>{}.obs;
  List<Map<String, dynamic>> objetos = [];
  Color  cor = Colors.grey[200] as Color ;

  ///get child => null;




  @override
  Widget build(BuildContext context) {
    for(int i = 0; i < widget.columns.length; i++) {
      if(widget.columns[i].typeWidget == "COLOR"){
        var cont  = (widget.columns[i].name.contains('.')
            ? widget.controller.mapPontos(widget.columns, i, widget.item)?.length
            : widget.item[widget.columns[i].name]?.length) ?? 0;


        if(cont > 0){
          cor = widget.columns[i].color!;
        }
      }
    }

    return GestureDetector(
      onTap: widget.onTap ,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        color: cor,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < widget.columns.length; i++)
              if(widget.columns[i].typeWidget != "COLOR")
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.columns[i].typeWidget == "TEXT")
                      Tooltip(
                        message: widget.controller.TextValues(widget.columns, widget.item, i),
                        child: Text(widget.controller.TextValues(widget.columns, widget.item, i),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.columns[i].textFontSize ?? 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (widget.columns[i].typeWidget == "ICONBUTTON")
                      IconButton(
                        onPressed: () {
                          if (widget.columns[i].onPressed != null) {
                            widget.columns[i].onPressed!(widget.item);
                          }
                        },
                        icon: Icon(widget.columns[i].icon),
                      )
                    else if (widget.columns[i].typeWidget == "CHECKBOX")
                      Obx(
                        () => Checkbox(
                          value: checkboxStates[i] ?? false,
                          onChanged: (bool? value) {
                            checkboxStates[i] = value ?? false;

                            widget.controller.setObj(
                                checkboxStates[i], widget.item, widget.count);

                            //if (widget.columns[i].onChanged != null) {
                            //  widget
                            //      .columns[i].onChanged!(widget.controller.obj);
                            //}
                          },
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

class ColumnModel {
  String name;
  String typeWidget;
  String? typeText;
  double? textFontSize;
  IconData? icon;
  Color? color;
  Future<void> Function(dynamic)? onPressed;
  Function(dynamic)? onChanged;


  ColumnModel({
    required this.name,
    required this.typeWidget,
    this.typeText,
    this.onPressed,
    this.textFontSize,
    this.icon,
    this.color,
    this.onChanged,
  });
}

enum TypeEnum {
  WidgetText('TEXT'),
  WidgetIconButton('ICONBUTTON'),
  WidgetCheckbox('CHECKBOX'),
  ContainerColor('COLOR'),
  TextText('TEXT'),
  TextData('DATA'),
  TextNumeros('NUMEROS');


  final String value;

  const TypeEnum(this.value);
}
