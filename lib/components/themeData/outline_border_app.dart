import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';

OutlineInputBorder outLineprimaryRaduis25 = OutlineInputBorder(
  borderRadius: BorderRadius.circular(25),
  borderSide: BorderSide(width: 1, color: ColorsApp.primaryColor),
);

OutlineInputBorder border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20),
);

OutlineInputBorder bordercircularGrey = OutlineInputBorder(
  borderRadius: BorderRadius.circular(25),
  borderSide: const BorderSide(color: Colors.grey),
);
