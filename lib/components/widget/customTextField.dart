// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items; // قائمة الخيارات
  final String hint; // نص التلميح
  final ValueChanged<String?> onChanged; // دالة للتعامل مع تغيير القيمة
  final String? Function(String)? displayMapper; // دالة لتحويل القيمة للعرض

  const CustomDropdown({
    required this.items,
    required this.hint,
    required this.onChanged,
    this.displayMapper,
    super.key,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue; // القيمة المحددة

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue,
        hint: Align(
          alignment: Alignment.centerRight, // محاذاة نص التلميح إلى اليمين
          child: Text(
            widget.hint,
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorsApp.primaryColor, // اللون الذي تريده للحواف
              width: 1.0, // سمك الحافة
            ),
          ),
      
          contentPadding: EdgeInsets.symmetric(horizontal: 12), // مسافة داخلية
          isDense: true,
        ),
        items: widget.items.map((String item) {
          final displayText = widget.displayMapper != null 
              ? widget.displayMapper!(item) 
              : item;
          
          return DropdownMenuItem<String>(
            value: item,
            child: Align(
              alignment: Alignment.centerRight, // محاذاة النص إلى اليمين
              child: Text(
                displayText ?? item, // 🔥 عرض النص المحول أو الأصلي
                style: const TextStyle(
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue; // تحديث القيمة المحددة
          });
          widget.onChanged(newValue); // استدعاء الدالة عند تغيير القيمة
        },
      ),
    );
  }
}
