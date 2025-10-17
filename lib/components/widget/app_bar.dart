import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';

class CAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          title,
          style: font15White,
        ),
      ),
      backgroundColor: ColorsApp.primaryColor,
      automaticallyImplyLeading: false, 
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
