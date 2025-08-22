import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';

/// هذه الويدجت تعرض صورة دائرية داخل [CircleAvatar] مع إمكانية تحديد
/// حجم الصورة ولون الخلفية. إذا لم يتم تحديد لون الخلفية، يستخدم اللون الأبيض افتراضيًا.
class CircleImage extends StatelessWidget {
  final double size;
  final String image;
  final Color? color;
  const CircleImage(
      {super.key, required this.size, required this.image, this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundColor: color ?? ColorsApp.white,
      backgroundImage: AssetImage(image),
    );
  }
}
