import 'package:flutter/material.dart';

class ShowWidget {
  static void showMessage(BuildContext context, String message, Color color, TextStyle textStyle) {
    // 🔥 التحقق مما إذا الـ context لا يزال نشطاً
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Center(
        child: Text(
          message,
          style: textStyle,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      duration: Duration(seconds: 2),
    ));
  }

}
