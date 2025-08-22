import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';

class PageViewScreen extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  const PageViewScreen({super.key, required this.image, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Column(
      children: [
        getHeight(50),
        SizedBox(
          height: media.height*.45,
          child: Image.asset(image)
          ),
        getHeight(15),
        Text(
          title,
          style: font15White,
        ),
        getHeight(5),
        Text(
          textAlign: TextAlign.center,
          subtitle,
          style: font11White,
        ),
      ],
    );
  }
}
