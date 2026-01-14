import 'package:flutter/material.dart';

import '../controller/custom_scaffold_controller.dart';
import '../interfaces/custom_scaffold_controller_interface.dart';

class CustomScaffoldView extends StatelessWidget {
  final Widget body;
  CustomScaffoldView({super.key, required this.body});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _menuItems = ['Entrada', 'Saida'];

  CustomScaffoldControllerInterface controller = CustomScaffoldController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003A88),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: null,// () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset(
                'assets/img/logo-ok-3.png',
                height: 45,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              child: _ProfileIcon(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: _menuItems.map((item) {
            return ListTile(
              title: Text(item),
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
                controller.handleMenuAction(item);
              },
            );
          }).toList(),
        ),
      ),
      body: body,
    );
  }
}


class _ProfileIcon extends StatelessWidget {

   _ProfileIcon({Key? key}) : super(key: key);

  CustomScaffoldControllerInterface controller = CustomScaffoldController();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person),
      onSelected: (String value) {
        controller.PopupMenuButton(value,context);

      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'Settings',
          child: Text('Settings'),
        ),
        const PopupMenuItem(
          value: 'Sign Out',
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}