import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';

/// زر مخصص قابل لإعادة الاستخدام في التطبيق
class ButtonApp extends StatelessWidget {
  final double? height;
  final double? width;
  final String textData;
  final TextStyle? textStyle;
  final BoxDecoration? boxDecoration;
  final VoidCallback? onTop;
  final Widget? child;

  const ButtonApp({
    super.key,
    this.height,
    this.width,
    required this.textData,
    this.textStyle,
    this.boxDecoration,
    this.onTop,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      height: height ?? media.height * .08 ,
      width: width ?? media.width * .85,
      decoration: boxDecoration ?? BoxDecoration(
        color: ColorsApp.primaryColor,
        borderRadius: BorderRadius.circular(25),
    ),
      child: TextButton(
        onPressed: onTop  ,
        child: child ?? Text( 
          textData, 
          style: textStyle ?? TextStyle(color: ColorsApp.white , fontSize: 13.sp))),
          
    );
  }
}
