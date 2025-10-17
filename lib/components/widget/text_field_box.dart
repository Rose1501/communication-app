import 'package:flutter/material.dart';

class TextFieldBox extends StatelessWidget {
  final  ValueChanged<String>?onChanged; // دالة للتحقق من الصحة
  final TextEditingController? controller; // تحكم في النص
  final String? errorText; // نص الخطأ
  final String hintText; // نص التلميح
  final int maxLines; // عدد الأسطر
  final bool filled; // هل الحقل ممتلئ
  final Color? fillColor; // لون الخلفية
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  const TextFieldBox({
    super.key,
    this.onChanged,
    this.controller,
    this.errorText,
    this.hintText = 'يرجى إدخال النص', // قيمة افتراضية
    this.maxLines = 5,
    this.filled = true,
    this.fillColor, 
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // استخدام controller الممرر
      focusNode: focusNode,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        filled: filled,
        fillColor: fillColor ?? Colors.grey[200], // لون افتراضي إذا لم يتم التحديد
        errorText: errorText, // استخدام errorText الممرر مباشرة
      ),
      validator: validator, 
      onChanged: onChanged,
    );
  }
}