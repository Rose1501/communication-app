import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/row_button_login_signup.dart';
import 'package:myproject/features/forget_password/view/forget_password_data.dart';
import 'package:myproject/features/forget_password/view/widget/form_forget_password.dart';
import 'package:myproject/features/onboarding/view/onboarding_data.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            getHeight(50),
            Expanded(
              child: Container(
                decoration: whiteRaduisTopLeftRight,
                child: SingleChildScrollView(
                  child: Column(
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
                      getHeight(120),
                      const FormForgetPassword(),
                      getHeight(20),
                      ButtonApp(
                        height: MediaQuery.of(context).size.height*.06,
                        textData: ForgetPasswordData.buttonText,
                        onTop: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
