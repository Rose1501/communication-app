// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';

class RecoveryPasswordBlocListener extends StatelessWidget {
  const RecoveryPasswordBlocListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('📱 حالة الـ Bloc في Recovery: ${state.status}');
        
        if (state.status == AuthStatus.resetPasswordSuccess) {
          print('✅ تم إعادة تعيين كلمة المرور بنجاح');
          
          ShowWidget.showMessage(
            context,
            'تم إعادة تعيين كلمة المرور بنجاح',
            Colors.green,
            font13White,
          );
          
          // العودة إلى شاشة Login بعد نجاح العملية
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.popUntil(context, (route) => route.isFirst);
          });
          
        } else if (state.status == AuthStatus.failure) {
          print('❌ خطأ في إعادة التعيين: ${state.errorMessage}');
          
          ShowWidget.showMessage(
            context,
            state.errorMessage ?? 'حدث خطأ أثناء إعادة التعيين',
            Colors.red,
            font13White,
          );
        }
      },
      child: child,
    );
  }
}