import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// دالة مساعدة لإنشاء مسافات رأسية
SizedBox getHeight(double height) {
  return SizedBox(height: height.h);
}
/// دالة مساعدة لإنشاء مسافات أفقية
SizedBox getWidth(double width) {
  return SizedBox(width: width.w);
}
