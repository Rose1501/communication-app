import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/function_app.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';

class ButtonRecoveryPassword extends StatelessWidget {
  const ButtonRecoveryPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final state = context.watch<AuthBloc>().state;
    final authBloc = context.read<AuthBloc>();
    
    if (state.status == AuthStatus.loading) {
      print('🔄 جاري إعادة تعيين كلمة المرور...');
      return Container(
        height: media.height * .06,
        width: media.width * .75,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextButton(
          onPressed: null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(radius: 15),
                SizedBox(width: 10),
                Text(
                  'جاري المعالجة...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return ButtonApp(
      height: media.height * .06,
      width: media.width * .75,
      textData: 'إعادة تعيين كلمة المرور',
      onTop: () {
  print('🔄 الضغط على زر إعادة التعيين');
  
  final formState = authBloc.formKey.currentState;
  if (formState != null) {
    // تحقق من كل حقل على حدة
    final codeError = _validateCode(authBloc.codeController.text);
    final passwordError = FunctionApp.validatePassword(authBloc.newPasswordController.text);
    final confirmError = authBloc.newPasswordController.text != authBloc.confirmPasswordController.text 
        ? 'كلمات المرور غير متطابقة' 
        : null;
    
    print('🔢 خطأ الرمز: $codeError');
    print('🔐 خطأ كلمة المرور: $passwordError');
    print('✅ خطأ التأكيد: $confirmError');
    
    final isValid = formState.validate();
    print('✅ حالة التحقق النهائية: $isValid');
    
    if (isValid) {
      final code = authBloc.codeController.text;
      final newPassword = authBloc.newPasswordController.text;
      
      print('🔢 الرمز: $code');
      print('🔐 كلمة المرور الجديدة: $newPassword');
      
      authBloc.add(ResetPasswordWithCodeRequested(
        code: code,
        newPassword: newPassword,
      ));
      print('✅ تم إرسال حدث ResetPasswordWithCodeRequested');
    } else {
      print('❌ النموذج غير صالح - يرجى تصحيح الأخطاء');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى تصحيح الأخطاء في النموذج'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
},
      child: Text(
        'إعادة تعيين كلمة المرور',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  // دالة التحقق من الرمز - إضافتها هنا
  String? _validateCode(String value) {
    if (value.isEmpty) {
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
}