import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/circle_image.dart';
import 'package:myproject/components/widget/row_button_login_signup.dart';
import 'package:myproject/features/login/bloc/login_bloc/login_bloc.dart';
import 'package:myproject/features/login/view/widget/button_login.dart';
import 'package:myproject/features/login/view/widget/form_login.dart';
import 'package:myproject/features/login/view/widget/login_bloc_lisen.dart';
import 'package:myproject/features/onboarding/view/onboarding_data.dart';
import 'package:user_repository/user_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorsApp.primaryColor,
      body:BlocProvider( 
        create: (context) => LoginBloc(
          userRepository: context.read<UserRepository>(),
        ),
        child: Column(
          children: [
            getHeight(70),
            Flexible(
              child: Container(
                decoration: whiteRaduisTopLeftRight,
                child: Column(
                  children: [
                    getHeight(media.height *.03),
                    const RowButtonLoginSignup(),
                    CircleImage(size: 55, image: LogoData.logo,),
                    getHeight(media.height *.09),
                    const FormLogin(),
                    getHeight(media.height *.06),
                    ButtonLogin(),
                    LoginBlocLisen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
