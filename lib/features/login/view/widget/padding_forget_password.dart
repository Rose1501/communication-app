import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/login/view/login_data.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: 
                      EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: (){context.pushNamed(Routes.forgetPassword);},
                            child:Text(LoginData.textForgetPassword,
                            style:font13black),
                          )
                        ],
                      ),
                      );
  }
}