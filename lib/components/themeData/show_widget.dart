import 'package:flutter/material.dart';

class ShowWidget {
  static void showMessage(
      BuildContext context, String message, Color color, TextStyle textStyle) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Center(
        child: Text(
          message,
          style: textStyle,
        ),
      ),
      duration: Duration(seconds: 2),
    ));
  }

}
