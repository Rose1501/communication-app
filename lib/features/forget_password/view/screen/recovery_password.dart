import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/row_button_login_signup.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/forget_password/view/widget/button_recovery_password.dart';
import 'package:myproject/features/forget_password/view/widget/form_recovery_password.dart';
import 'package:myproject/features/forget_password/view/widget/recovery_password_bloclistener.dart';
//import 'package:myproject/features/forget_password/view/widget/recovery_password_listener.dart';
import 'package:myproject/features/onboarding/view/onboarding_data.dart';
import 'package:user_repository/user_repository.dart';

class RecoveryPassword extends StatelessWidget {
  final String email;
  const RecoveryPassword({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // إعادة استخدام الـ Bloc الحالي أو إنشاء جديد إذا لزم الأمر
      create:
          (context) => AuthBloc(userRepository: context.read<UserRepository>())
            ..add(EmailSetEvent(email)), // تعيين البريد الإلكتروني في الحالة
      child: Scaffold(
        backgroundColor: ColorsApp.primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              getHeight(50),
              Expanded(
                child: Container(
                  decoration: whiteBorder35,
                  child: RecoveryPasswordBlocListener(
                    child: SingleChildScrollView(
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
                            'إعادة تعيين كلمة المرور',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorsApp.black,
                            ),
                          ),
                          getHeight(10),
                          Text(
                            'البريد الإلكتروني: $email',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          getHeight(20),
                          FormRecoveryPassword(email: email),
                          getHeight(30),
                          ButtonRecoveryPassword(),
                          getHeight(20),
                        ],
                      ),
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
