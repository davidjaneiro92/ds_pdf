import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CustomListTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: Icon(icon),
      trailing: trailing ?? const Icon(CupertinoIcons.forward, size: 18),
      onTap: onTap ?? () {},
    );
  }
}