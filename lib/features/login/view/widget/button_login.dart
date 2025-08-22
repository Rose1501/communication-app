import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/widget/bottom_app.dart';

class ButtonLogin extends StatelessWidget {
  const ButtonLogin({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
      return  ButtonApp(
          width: media.width *.75,
          height: media.height *.06,
          textData: 'تسجيل دخول', 
          onTop: (){}
          );
  }
}
