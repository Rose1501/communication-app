// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomCardInfo extends StatelessWidget {
  final String titleCard;
  final String titleSubCard;
  final Icon icon;

  const CustomCardInfo({
    super.key,
    required this.titleCard,
    required this.titleSubCard,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Align(
          alignment: Alignment.centerRight, // محاذاة العنوان إلى اليمين
          child: Text(
            titleCard,
            textAlign: TextAlign.right, // محاذاة النص إلى اليمين
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        subtitle: Align(
          alignment: Alignment.centerRight, // محاذاة العنوان الفرعي إلى اليمين
          child: Text(
            titleSubCard,
            textAlign: TextAlign.right, // محاذاة النص إلى اليمين
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        leading: icon,
      ),
    );
  }
}