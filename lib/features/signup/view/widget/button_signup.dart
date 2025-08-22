import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myproject/components/widget/bottom_app.dart';
import 'package:myproject/features/signup/view/singnup_data.dart';

class ButtonSignup extends StatelessWidget {
  const ButtonSignup({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ButtonApp(
      width: media.width * .75,
      height: media.height * .06,
      textData: SingnupData.buttonSingnup,
      onTop: () {
        // أضف عملية إنشاء حساب هنا
      },
    );
  }
}
