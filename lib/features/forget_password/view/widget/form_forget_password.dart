// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/function_app.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/forget_password/view/forget_password_data.dart';

class FormForgetPassword extends StatelessWidget {
  const FormForgetPassword({super.key,});

  @override
  Widget build(BuildContext context) {
    // اختبار مؤقت
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final email = context.read<AuthBloc>().emailController.text;
    print('📧 البريد الحالي: "$email"');
    print('✅ التحقق: ${FunctionApp.validateEmail(email)}');
  });
  
    return Form(
      key: context.read<AuthBloc>().formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
                CustomTextFiled(
                  controller: context.read<AuthBloc>().emailController,
                  hintText: ForgetPasswordData.emailText,
                  icon: ForgetPasswordData.email,
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  
                  final error = FunctionApp.validateEmail(value);
                  if (error.isNotEmpty) {
                    return error;
                  }
                  
                  return null;
                },
                ),
                SizedBox(height: 20.h),
                // عرض حالة التحقق
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final email = context.read<AuthBloc>().emailController.text;
                  if (email.isNotEmpty) {
                    final error = FunctionApp.validateEmail(email);
                    if (error.isNotEmpty) {
                      return Text(
                        error,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.right,
                      );
                    }
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
