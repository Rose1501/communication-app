import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';

class RowImageTwo extends StatelessWidget {
  const RowImageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 120.w),
                      child: CircleAvatar(
                      radius: 16,
                      backgroundColor: ColorsApp.white,
                    ),
                    ),
                  ],
                );
  }
}