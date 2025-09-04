import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/login/bloc/login_bloc/login_bloc.dart';

class LoginBlocLisen extends StatelessWidget {
  const LoginBlocLisen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        print('BlocListener<LoginBloc>');
        if (state is LoginSuccess) {
          ShowWidget.showMessage(
            context,
            'Login successful',
            Colors.green,
            font13White,
          );
          context.pushAndRemoveUntil(Routes.home);
        } else if (state is LoginFailure) {
          ShowWidget.showMessage(
            context,
            state.message,
            Colors.red,
            font13White,
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
