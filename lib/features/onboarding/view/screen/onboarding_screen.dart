import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/components/widget/circle_image.dart';
import 'package:myproject/features/onboarding/view/onboarding_data.dart';
import 'package:myproject/features/onboarding/view/widget/row_image_one.dart';
import 'package:myproject/features/onboarding/view/widget/row_image_two.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: media.height,
                width: media.width,
                decoration: primaryBorderBotomright380,
                child: Column(
                  children: [
                    getHeight(80),
                    CircleImage(image: LogoData.logo,size: 30,color: ColorsApp.white,),
                    getHeight(10),
                    const RowImageOne(),
                    getHeight(10),
                    const RowImageTwo(),
                    getHeight(50),
                    ButtonApp(
                      textData: OnboardingData.textLogin,
                      textStyle: font13Primary,
                      boxDecoration: whiteBorder25,
                      onTop: () {
                        context.pushNamed(Routes.login);
                      },
                    ),
                    getHeight(15),
                    ButtonApp(
                      textData: OnboardingData.textSinup,
                      textStyle: font13Primary,
                      boxDecoration: whiteBorder25,
                      onTop: () {context.pushNamed(Routes.signup);},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
