import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/text_style.dart';

/// هذه الويدجت توفر حقل إدخال نصي قابل للتخصيص بالكامل مع دعم للعديد من الميزات:
/// - إضافة أيقونات مسبقة و لاحقة
/// - دعم حقول كلمات المرور (إظهار/إخفاء النص)
/// - التحقق من صحة البيانات (validation)
/// - تخصيص التصميم والأبعاد
/// - أنواع مختلفة من لوحات المفاتيح
class CustomTextFiled extends StatefulWidget {
  final String hintText; 
  final String icon; 
  final bool? isPassword;
  final TextEditingController? controller; 
  final String? suffixIcon; 
  final TextStyle? textStyle;
  final TextStyle? hintStyle; 
  final TextInputType? keyboardType; 
  final String? Function(String?)? validator;
  final double? heightField; 
  final double? widthField;  
  const CustomTextFiled(
      {super.key, 
      this.heightField,
      this.widthField,
      this.validator,
      this.keyboardType,
      this.hintStyle,
      required this.hintText, required this.icon , this.isPassword = false , this.controller , this.suffixIcon , this.textStyle});

  @override
  State<CustomTextFiled> createState() => _CustomTextFiledState();
}

class _CustomTextFiledState extends State<CustomTextFiled> {
  bool isEyes = true;
  
  void fun(){
    setState(() {
      isEyes = !isEyes;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
        height: widget.heightField ?? media.height * .06,
        child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword! && !isEyes ==false,
        style:    widget.textStyle ?? black12W600,
        decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle:  widget.hintStyle ?? black12W600,
        prefixIcon: Image.asset(widget.icon),
        suffixIcon: widget.isPassword! ? 
            IconButton(onPressed: fun, iconSize: 16, color: Colors.grey, 
              icon: Icon( isEyes ? Icons.visibility : Icons.visibility_off))  :
                widget.suffixIcon  == null ? null : Image.asset(widget.suffixIcon!),
        enabledBorder:  outLineprimaryRaduis25,
        focusedBorder: outLineprimaryRaduis25,
        ),
      ),
    );
    
  }
}
