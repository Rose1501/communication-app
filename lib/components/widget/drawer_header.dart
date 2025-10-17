// ignore_for_file: prefer_typing_uninitialized_variables, strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/features/home/view/home_data.dart';

class DrawerHeaderApp extends StatelessWidget {
  final userModel;
  const DrawerHeaderApp({super.key, 
  required this.userModel});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: ColorsApp.primaryColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: ColorsApp.white,
            backgroundImage:
                userModel.urlImg!.isEmpty
                    ? AssetImage(HomeData.imageHomePage)
                    : null,
          ),
          const SizedBox(height: 5),
          Text(
            userModel.name,
            style: TextStyle(
              fontFamily: userModel.name,
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
