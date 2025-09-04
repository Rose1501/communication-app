import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/connenct.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/show_widget.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/signup/bloc/signup_bloc.dart';
import 'package:myproject/features/signup/view/singnup_data.dart';
import 'package:user_repository/user_repository.dart';

class ButtonSignup extends StatelessWidget {
  const ButtonSignup({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final state = context.watch<SignUpBloc>().state;
    final signupBloc = context.read<SignUpBloc>();
    if (state is SignUpProcess) {
      print('SignUpProcess state');
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
      textData: SingnupData.buttonSingnup,
      onTop: () async {
        print('SignUp button pressed');

        // ✅ التحقق من الاتصال قبل الإرسال
        final isConnected = await checkInternetconnection();
        if (!isConnected) {
          ShowWidget.showMessage(context, noNet, Colors.black, font11White);
          return;
        }

        
        if (signupBloc.formKey.currentState!.validate()) {
          UserModels myUser = UserModels.empty;
          myUser = myUser.copyWith(
            email: signupBloc.email.text,
            userID: signupBloc.id.text,
          );
          signupBloc.add(SignUpRequired
          (myUser, signupBloc.password.text));
        }
      },
    );
  }
}
