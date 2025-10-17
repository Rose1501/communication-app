// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';

class ForgetPasswordBlocListener extends StatelessWidget {
  const ForgetPasswordBlocListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('📱 حالة الـ Bloc: ${state.status}');
        if (state.status == AuthStatus.resetCodeSent) {
          print('✅ تم إرسال الرمز بنجاح إلى: ${state.email}');
          ShowWidget.showMessage(
            context,
            'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني',
            Colors.green,
            font13White,
          );
          // الانتقال إلى شاشة إدخال الرمز بعد تأخير بسيط
          Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushNamed(
          context, 
          Routes.recoveryPassword,
          arguments: state.email,
        );
          });
        } else if (state.status == AuthStatus.failure) {
          print('❌ خطأ: ${state.errorMessage}');
          ShowWidget.showMessage(
            context,
            state.errorMessage ?? 'حدث خطأ أثناء إرسال الرمز',
            Colors.red,
            font13White,
          );
        }
      },
      child: child,
    );
  }
}
