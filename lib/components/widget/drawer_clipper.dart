import 'package:flutter/material.dart';

class DrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // ابدأ المسار من الزاوية العلوية اليسرى
    path.lineTo(0, size.height * 0.60);
    // رسم منحنى بيزير
    path.quadraticBezierTo(
      size.width * 0.10, // نقطة التحكم في منتصف العرض
      size.height * 0.85, // نقطة التحكم أعلى من خط القاعدة
      size.width, // النهاية عند الزاوية السفلية اليمنى
      size.height - 120, // انخفاض النهاية
    );
    // الانتقال إلى الزاوية العلوية اليمنى
    path.lineTo(size.width, 0);
    path.close(); // إغلاق الشكل
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}