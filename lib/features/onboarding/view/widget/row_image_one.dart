import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';

class RowImageOne extends StatelessWidget {
  const RowImageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: CircleAvatar(
                      radius: 30,
                      backgroundColor: ColorsApp.white,
                    ),
                    ),
                  ],
                );
  }
}