import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/onboarding/view/onboarding_data.dart';

class UpperBar extends StatelessWidget {
  const UpperBar({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
                height: media.height * 0.60,
                width: media.width,
                decoration: borderRightprimary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: 
                      Text(OnboardingData.title,style: font15Whitebold,),
                    ),
                    getHeight(10),
                    Text(OnboardingData.subtitle,style: font13White,textAlign: TextAlign.center,),
                  ],
                ),
              )
      ],
    );
  }
}
