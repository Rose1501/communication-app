import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/connenct.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/login/bloc/login_bloc/login_bloc.dart';

class ButtonLogin extends StatelessWidget {
  const ButtonLogin({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final state = context.watch<LoginBloc>().state;
    final loginBloc = context.read<LoginBloc>();
    if (state is LoginProcess) {
      print('LoginProcess state');
      return Container(
        height: media.height * .06,
        width: media.width * .75,
        decoration: primaryRaduis25,
        child: TextButton(
          onPressed: null,
          child: Center(child: CupertinoActivityIndicator(radius: 15)),
        ),
      );
    }
    return ButtonApp(
      width: media.width * .75,
      height: media.height * .06,
      textData: 'تسجيل دخول',
      onTop: () async {
        print('Login button pressed');
        
        // ✅ التحقق من الاتصال قبل الإرسال
        final isConnected = await checkInternetconnection();
        if (!isConnected) {
          ShowWidget.showMessage(context, noNet, Colors.black, font11White);
          return;
        }
        
        
        if (loginBloc.formKey.currentState!.validate()) {
          loginBloc.add(LoginRequired
            (loginBloc.email.text, loginBloc.password.text),
          );
        }
      },
    );
  }
}
