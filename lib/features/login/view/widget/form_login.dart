
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/function_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/login/view/login_data.dart';
import 'package:myproject/features/login/view/widget/padding_forget_password.dart';


class FormLogin extends StatefulWidget {
  const FormLogin({super.key});

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    return Form(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          CustomTextFiled(
            validator: (value) {
              String error = FunctionApp.validateEmail(value.toString());
              if(error.isNotEmpty) return error;
              return null;
            },
            controller:email,
            hintText: LoginData.textemail,
            textStyle: font13black, 
            icon: LoginData.email),
          getHeight(10),
          CustomTextFiled(
            validator: (value) {
              String error = FunctionApp.validatePassword(value.toString());
              if (error.isNotEmpty) return error;
              return null;
            },
            controller:password,
            hintText: LoginData.textpassword, 
            textStyle: font13black,
            icon: LoginData.password , isPassword: true,),
            
          getHeight(5),
          const ForgetPassword()
        ],
      ),
    ));
    
  }
}
