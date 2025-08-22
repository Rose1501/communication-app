import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/forget_password/view/forget_password_data.dart';

class FormForgetPassword extends StatelessWidget {
  const FormForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
                CustomTextFiled(
              hintText: ForgetPasswordData.emailText,
              icon: 'assets/icons/email.png',
            ),
            ],
          ),
        ),
      ),
    );
  }
}
