import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/widget/circle_image.dart';
import 'package:myproject/components/widget/row_button_login_signup.dart';
import 'package:myproject/features/onboarding/view/onboarding_data.dart';
import 'package:myproject/features/signup/view/widget/button_signup.dart';
import 'package:myproject/features/signup/view/widget/form_signup.dart';

class Signupscreen extends StatelessWidget {
  const Signupscreen({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorsApp.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            getHeight(70),
            Expanded(
              child: Container(
                decoration: whiteBorder25,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      getHeight(media.height * .03),
                      RowButtonLoginSignup(),
                      CircleImage(size: 55, image: LogoData.logo),
                      getHeight(media.height * .05),
                      const SignupForm(),
                      getHeight(media.height * .07),
                      ButtonSignup(),
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
