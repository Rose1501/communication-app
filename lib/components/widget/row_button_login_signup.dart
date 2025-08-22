import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';

/// هذه الويدجت تعرض زر دائري بسهم للتنقل إلى الشاشة السابقة (الرجوع)
/// مصمم خصيصًا للاستخدام في شاشات  (تسجيل الدخول/انشاء حساب)
class RowButtonLoginSignup extends StatelessWidget {
  const RowButtonLoginSignup({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorsApp.primaryColor,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context); // زر الرجوع
                                },
                                icon: Icon(
                                  Icons.arrow_forward_sharp,
                                  color: ColorsApp.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
    );
  }
}