import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/function_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/signup/view/singnup_data.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
    return Form(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            CustomTextFiled(
              validator: (value) {
                    String error = FunctionApp.validateStudentId(value.toString());
                    if (error.isNotEmpty) return error;
                    return null;
                  },
              hintText: SingnupData.textOne,
              icon: SingnupData.idName,
              keyboardType: TextInputType.number,
              controller:controllerName, // تأكد من تعيين controller,
            ),
            getHeight(20),
            CustomTextFiled(
              validator: (value) {
                    String error = FunctionApp.validateEmail(value.toString());
                    if (error.isNotEmpty) return error;
                    return null;
                  },
              hintText: SingnupData.textTwo,
              icon: SingnupData.email,
              controller:controllerEmail, // تأكد من تعيين controller,
            ),
            getHeight(20),
            CustomTextFiled(
                validator: (value) {
                  String error = FunctionApp.validatePassword(value.toString());
                  if (error.isNotEmpty) return error;
                  return null;
                },
              hintText: SingnupData.textThree,
              icon: SingnupData.password,
              isPassword: true,
              controller:controllerPassword, // تأكد من تعيين controller,
            ),
          ],
        ),
      ),
    );
  }
}














/*import 'package:c/core/them/colorApp/colors_app.dart';
import 'package:flutter/material.dart';

class FormSignup extends StatefulWidget {
  final String hintText;
  final String icon;
  final bool? isPassword;
  final TextEditingController? controller;
  const FormSignup({super.key,
  required this.hintText, 
    required this.icon, 
    this.isPassword=false, 
    this.controller});

  @override
  State<FormSignup> createState() => _FormSignupState();
}

class _FormSignupState extends State<FormSignup> {
bool isEyes = false;

  void fun() {
    setState(() {
      isEyes = !isEyes;
    });
  }



  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword! && isEyes == false,
      style: TextStyle(fontSize: 22.0),
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        suffixIcon: Image.asset(
          widget.icon,
          color: ColorsApp.primaryColor,
        ),
        prefixIcon: widget.isPassword!
                  ? SizedBox(
                    width: media.width*.25,
                    child: IconButton(
                    onPressed: fun,
                    iconSize: 25,
                    color: ColorsApp.primaryColor,
                    icon: Icon(
                      isEyes ? Icons.visibility : Icons.visibility_off,
                    ),
                  ) ,
                  )
                  : null,
        hintText: widget.hintText,
        hintStyle: TextStyle(fontFamily: 'Cairo'),
        border: InputBorder.none,
      ),
    );
  }
}*/