import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/row_button_login_signup.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/forget_password/view/widget/button_forget_password.dart';
import 'package:myproject/features/forget_password/view/widget/forget_password_bloclistener.dart';
import 'package:myproject/features/forget_password/view/widget/form_forget_password.dart';
import 'package:myproject/features/onboarding/view/onboarding_data.dart';
import 'package:user_repository/user_repository.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        userRepository: context.read<UserRepository>(),
      ),
      child: Scaffold(
        backgroundColor: ColorsApp.primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              getHeight(50),
              Expanded(
                child: Container(
                  decoration: whiteRaduisTopLeftRight,
                  child: ForgetPasswordBlocListener(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              getHeight(10),
                              RowButtonLoginSignup(),
                              getHeight(20),
                              Center(
                                child: CircleAvatar(
                                  radius: 65,
                                  backgroundColor: ColorsApp.white,
                                  backgroundImage: AssetImage(LogoData.logo),
                                ),
                              ),
                              getHeight(40),
                              Text(
                                'استعادة كلمة المرور',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsApp.black,
                                ),
                              ),
                              getHeight(20),
                              const FormForgetPassword(),
                              getHeight(30),
                              const ButtonForgetPassword(),
                              getHeight(20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'سيتم إرسال رمز تحقق إلى بريدك الإلكتروني لإعادة تعيين كلمة المرور',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              getHeight(40),
                            ],
                          ),
                        ),
                      ),
                      );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}