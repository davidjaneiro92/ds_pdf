import 'package:ds_pdf/src/components/custom_list_view/view/custom_item_list_view.dart';
import 'package:flutter/material.dart';

class CustomListViewConteiner extends StatelessWidget {
  final List<dynamic> objectList;
  List<ColumnModel> clunm;
  final Future<void> Function(dynamic)? onTapConteiner;

  CustomListViewConteiner(
      {super.key,
      required this.objectList,
      required this.clunm,
      this.onTapConteiner});

  final TextEditingController buscarDanfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //componente de busca se precisar
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: buscarDanfController,
            //         decoration: InputDecoration(
            //           border: OutlineInputBorder(),
            //           labelText: 'Buscar',
            //           //hintText: '',
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 8,),
            //     ElevatedButton(
            //         onPressed: (){
            //           String text = buscarDanfController.text;
            //           setState(() {
            //             //Danf newTodo = Danf(
            //              // title: text,
            //              // dateTime: DateTime.now(),
            //            // );
            //             //danf.add( newTodo);
            //           });
            //         },
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.blueAccent,
            //           padding: const EdgeInsets.all(15),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(5),
            //           ),
            //         ),
            //         child: Icon(
            //           Icons.search,
            //           size: 30,
            //           color: Colors.white,
            //         )
            //     ),
            //   ],
            // ),
            // SizedBox(height: 16,),
            Flexible(
              child: objectList.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum registro encontrado.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (int count = 0; count < objectList.length; count++) ...{
                          //for (dynamic nf in objectList) ...{
                          CustomItemListView(
                            columns: clunm,
                            item: objectList[count].toMap(),
                            count: count,
                            onTap: () async {
                              await onTapConteiner!(objectList[count].toMap());
                            },
                          ),
                        },
                      ],
                    ),
            ),
            const SizedBox(
              height: 16,
            ),

            ///Roberto pediu para retirar a quatidade de linhas
            // Row(
            //   children: [
            //     Expanded(
            //       child: Text(
            //         'Você possui ${objectList.length} Linhas',
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
