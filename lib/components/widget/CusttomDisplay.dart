// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
//إنشاء نافذة تأكيد قابلة لإعادة الاستخدام
class ConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String message,
    String? imagePath,
    String confirmText = 'نعم',
    String cancelText = 'لا',
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'تـأكيد',
                  style: TextStyle(
                    color: ColorsApp.blackDark,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorsApp.blackDark),
                ),
                const SizedBox(height: 16),
                if (imagePath != null) ...[
                  const SizedBox(height: 16),
                  Image.asset(imagePath, height: 100, width: 100),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        cancelText,
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child:
                      Text(
                        confirmText,
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ?? Future.value(false);
  }
}