import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';

class PasswordModeSwitch extends StatelessWidget {
  final bool isResetMode;
  final VoidCallback onNormalMode;
  final VoidCallback onResetMode;

  const PasswordModeSwitch({
    super.key,
    required this.isResetMode,
    required this.onNormalMode,
    required this.onResetMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onNormalMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: isResetMode 
                  ? Colors.grey 
                  : ColorsApp.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'بكلمة المرور الحالية',
              style: font15White,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ElevatedButton(
            onPressed: onResetMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: isResetMode 
                  ? ColorsApp.primaryColor 
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'بالبريد الإلكتروني',
              style: font15White,
            ),
          ),
        ),
      ],
    );
  }
}