import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';

class CustomTimeField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData? iconData;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double? heightField;
  final double? widthField;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final Color? disabledFillColor;
  final Color? iconColor;
  final Color? hintColor;
  final Color? textColor;

  const CustomTimeField({
    super.key,
    required this.hintText,
    required this.controller,
    this.iconData,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.textStyle,
    this.hintStyle,
    this.heightField,
    this.widthField,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.disabledFillColor,
    this.iconColor,
    this.hintColor,
    this.textColor,
  });

  @override
  State<CustomTimeField> createState() => _CustomTimeFieldState();
}

class _CustomTimeFieldState extends State<CustomTimeField> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    // تحديد الألوان بناءً على الحالة
    final enabledBorderColor = widget.enabledBorderColor ?? ColorsApp.primaryColor;
    final focusedBorderColor = widget.focusedBorderColor ?? ColorsApp.primaryColor;
    final fillColor = widget.fillColor ?? ColorsApp.white;
    final disabledFillColor = widget.disabledFillColor ?? const Color(0xFFF5F5F5);
    final iconColor = widget.iconColor ?? ColorsApp.primaryColor;
    final hintColor = widget.hintColor ?? ColorsApp.black;
    final textColor = widget.textColor ?? ColorsApp.black;
    
    return InkWell(
      onTap: widget.onTap,
      child: IgnorePointer(
        ignoring: widget.readOnly,
        child: SizedBox(
          height: widget.heightField ?? media.height * .06,
          child: TextFormField(
            controller: widget.controller,
            readOnly: widget.readOnly,
            style: widget.textStyle ?? black12W600.copyWith(color: textColor),
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: widget.hintStyle ?? black12W600.copyWith(color: hintColor),
              prefixIcon: widget.iconData != null 
                ? Icon(
                    widget.iconData,
                    color: iconColor,
                  ) 
                : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: enabledBorderColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: focusedBorderColor,
                  width: 2.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: ColorsApp.grey,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: ColorsApp.red,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: ColorsApp.red,
                  width: 2.0,
                ),
              ),
              filled: true,
              fillColor: widget.readOnly ? disabledFillColor : fillColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ),
    );
  }
}