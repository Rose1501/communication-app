import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/function_app.dart';
import 'package:myproject/components/widget/text_filed.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';

class FormRecoveryPassword extends StatelessWidget {
  final String email;
  const FormRecoveryPassword({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    // validator للرمز
  String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الرمز';
    }
    if (value.length != 6) {
      return 'الرمز يجب أن يكون 6 أرقام';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'الرمز يجب أن يحتوي على أرقام فقط';
    }
    return null;
  }

  // validator لتأكيد كلمة المرور
  String? validateConfirmPassword(String? value) {
    final newPassword = context.read<AuthBloc>().newPasswordController.text;
    if (value != newPassword) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }
    // في build method of FormRecoveryPassword، تحقق
    WidgetsBinding.instance.addPostFrameCallback((_) {
  final formState = context.read<AuthBloc>().formKey.currentState;
  print('🔑 حالة formKey: ${formState != null ? "موجود" : "null"}');
    });
    return Form(
      key: context.read<AuthBloc>().formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            CustomTextFiled(
              controller: context.read<AuthBloc>().codeController,
              hintText: 'أدخل الرمز المكون من 6 أرقام',
              iconData: Icons.confirmation_number,
              keyboardType: TextInputType.number,
              validator:validateCode, /*(value) {
                if (value!.isEmpty) return 'الرجاء إدخال الرمز';
                if (value.length != 6) return 'الرمز يجب أن يكون 6 أرقام';
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'الرمز يجب أن يحتوي على أرقام فقط';
                }
                return null;
              },*/
            ),
            SizedBox(height: 20.h),
            CustomTextFiled(
              controller: context.read<AuthBloc>().newPasswordController,
              hintText: 'كلمة المرور الجديدة',
              iconData: Icons.lock,
              isPassword: true,
              validator: (value) {
                final error = FunctionApp.validatePassword(value ?? '');
                return error.isNotEmpty ? error : null;
              },
            ),
            SizedBox(height: 20.h),
            CustomTextFiled(
              controller: context.read<AuthBloc>().confirmPasswordController,
              hintText: 'تأكيد كلمة المرور الجديدة',
              iconData: Icons.lock_outline,
              isPassword: true,
              validator: validateConfirmPassword,/*(value) {
                if (value != context.read<AuthBloc>().newPasswordController.text) {
                  return 'كلمات المرور غير متطابقة';
                }
                return null;
              },*/
            ),
            // في FormRecoveryPassword، أضف هذا للاختبار
SizedBox(height: 20.h),
ElevatedButton(
  onPressed: () {
    // تعبئة تلقائية للاختبار
    final authBloc = context.read<AuthBloc>();
    authBloc.codeController.text = '123456';
    authBloc.newPasswordController.text = '123456';
    authBloc.confirmPasswordController.text = '123456';
    
    // إعادة التحقق
    authBloc.formKey.currentState?.validate();
  },
  child: Text('تعبئة تلقائية للاختبار'),
),
          ],
        ),
      ),
    );
  }
}