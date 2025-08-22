import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';

class ContainerScroll extends StatelessWidget {
  final bool selected;
  const ContainerScroll({super.key, required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.symmetric(horizontal: 4.0.w),
      width: selected ? 50 : 24.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: selected ? ColorsApp.primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
