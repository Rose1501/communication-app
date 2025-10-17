import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';

class ContainreLine extends StatelessWidget {
  const ContainreLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            height: 3,
            color: ColorsApp.grey,
            width: double.infinity,
          );
  }
}