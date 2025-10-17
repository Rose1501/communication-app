import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final String url;
  final double? height;
  final Widget? widget;
  final double? width;

  const LoadingWidget({super.key, required this.url, this.height, this.widget, this.width});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
      height: height ?? media.height * .15,
      width: width?? media.width * .4,
      child: Column(children: [Lottie.asset(url), widget ?? SizedBox.shrink()]),
    );
  }
}
