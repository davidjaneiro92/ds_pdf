import 'package:flutter/cupertino.dart';

abstract class CustomScaffoldControllerInterface
{
  void handleMenuAction(String item);

  void handleSignOut();

  void PopupMenuButton(String item, BuildContext context );
}