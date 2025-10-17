// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';

class CustomAppBarTitle extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? showButton;
  const CustomAppBarTitle({super.key, 
  required this.title, 
  this.showButton=false,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      backgroundColor: ColorsApp.primaryColor,
      leading: showButton == true
          ? IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              onPressed: () {
                context.pushNamed(Routes.about);
              },
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
