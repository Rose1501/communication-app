import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/signup/bloc/signup_bloc.dart';

class SignupBlocListener extends StatelessWidget {
  const SignupBlocListener({super.key});
//flutter run -d chrome
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        print('BlocListener<SignUpBloc>state: $state');
        if (state is SignUpSuccess) {
          ShowWidget.showMessage(
            context,
            'تم إنشاء الحساب بنجاح',
            Colors.green,
            font13White,
          );
          print('SignUpSuccess');
          
          // تأكد من أن context صالح للتنقل
          WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pushAndRemoveUntil(Routes.home);
            });
        } else if (state is SignUpFailure) {
          ShowWidget.showMessage(
            context,
            state.message,
            Colors.red,
            font13White,
          );
          print('SignUpFailure: ${state.message}');
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
