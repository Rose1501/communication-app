// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/forget_password/view/forget_password_data.dart';

class ButtonForgetPassword extends StatelessWidget {
  const ButtonForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final state = context.watch<AuthBloc>().state;
    final authBloc = context.read<AuthBloc>();
    if (state.status == AuthStatus.loading) {
      print('🔄 AuthProcess state - جاري إرسال الرمز...');
      return Container(
        height: media.height * .06,
        width: media.width * .75,
        decoration: primaryRaduis25,
        child: TextButton(
          onPressed: null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(radius: 15),
                SizedBox(width: 10),
                Text(
                  'جاري الإرسال...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        ButtonApp(
          height: 50,
          textData: ForgetPasswordData.buttonText,
          onTop:() {
            print('🔄 الضغط على زر إرسال الرمز');
            
            final formState = authBloc.formKey.currentState;
            if (formState != null) {
              // التحقق من الصحة وعرض الأخطاء
              final isValid = formState.validate();
              print('✅ حالة التحقق: $isValid');
              
              if (isValid) {
                final email = authBloc.emailController.text.trim();
                print('📧 إرسال رمز إلى: $email');
                
                authBloc.add(SendResetCodeRequested(email));
                print('✅ تم إرسال حدث SendResetCodeRequested');
              } else {
                print('❌ النموذج غير صالح - يرجى تصحيح الأخطاء');
                
                // عرض رسالة تنبيه للمستخدم
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('يرجى تصحيح الأخطاء في النموذج'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              print('❌ النموذج غير صالح');
            }
          },
          child: Text(
            ForgetPasswordData.buttonText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // عرض رسالة توضيحية
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'أدخل البريد الإلكتروني المسجل في النظام',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
