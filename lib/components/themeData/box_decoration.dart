import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';

BoxDecoration redBorder25 = BoxDecoration(
  borderRadius: BorderRadius.circular(26),
  color: Colors.red,
);

BoxDecoration whiteBorder25 = BoxDecoration(
  borderRadius: BorderRadius.circular(26),
  color: Colors.white,
);

BoxDecoration imageBackground(String image) {
  return BoxDecoration(
    image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
  );
}

BoxDecoration borderRightprimaryl = BoxDecoration(
  borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
  color: ColorsApp.primaryLight,
);

BoxDecoration borderRightprimary = BoxDecoration(
  borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
  color: ColorsApp.primaryColor,
);

BoxDecoration borderRightLeftprimary = BoxDecoration(
  color: ColorsApp.primaryColor,
  borderRadius: BorderRadius.only(
    bottomRight: Radius.circular(25),
    topLeft: Radius.circular(25),
  ),
);
BoxDecoration borderLeftwhite = BoxDecoration(
  borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
  color: ColorsApp.white,
);

BoxDecoration borderbottomprimary = BoxDecoration(
  color: ColorsApp.primaryColor,
  borderRadius: BorderRadius.only(
    bottomRight: Radius.circular(25),
    topLeft: Radius.circular(25),
  ),
);

BoxDecoration borderRadiusShadoWhite = BoxDecoration(
  color: Colors.white,
  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20.0)],
  borderRadius: BorderRadius.only(
    topRight: Radius.circular(90.0),
    bottomRight: Radius.circular(90.0),
  ),
);

BoxDecoration bordererLinePrimary = BoxDecoration(
  border: Border.all(color: ColorsApp.primaryColor),
);

BoxDecoration imageBackGround(String image) {
  return BoxDecoration(
    image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
  );
}

BoxDecoration whiteImageShapeCircle = BoxDecoration(
  image: const DecorationImage(image: AssetImage('assets/images/logo.png')),
  color: ColorsApp.white,
  shape: BoxShape.circle,
);

BoxDecoration primaryBorderBottomRight380 = BoxDecoration(
  color: ColorsApp.primaryColor,
  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(380)),
);

BoxDecoration primaryRaduis25BorderAllWhite = BoxDecoration(
  borderRadius: BorderRadius.circular(25),
  color: ColorsApp.primaryColor,
  border: Border.all(width: 1, color: ColorsApp.white),
);

BoxDecoration whiteRaduisTopLeftRight = BoxDecoration(
  color: ColorsApp.white,
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(40),
    topRight: Radius.circular(40),
  ),
);

OutlineInputBorder outLineprimaryRaduis25 = OutlineInputBorder(
  borderRadius: BorderRadius.circular(25),
  borderSide: BorderSide(width: 1, color: ColorsApp.primaryColor),
);

BoxDecoration whiteBorder35 = BoxDecoration(
  borderRadius: BorderRadius.circular(35),
  color: Colors.white,
);

BoxDecoration primaryBorderBotomright380 =BoxDecoration(
              color: ColorsApp.primaryColor,
              borderRadius: const  BorderRadius.only(
                bottomRight: Radius.circular(380), ) ,);


BoxDecoration whiteBordercircular35 =BoxDecoration(
  
                  color: ColorsApp.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
)   );  


  OutlineInputBorder primaryraduis25 =     OutlineInputBorder(
  borderRadius: BorderRadius.circular(25),
  borderSide: BorderSide(
    width: 1,
    color: ColorsApp.primaryColor,
  ),
);

BoxDecoration primaryRaduis25 = BoxDecoration(
  color: ColorsApp.primaryColor,
  borderRadius: BorderRadius.circular(25),
);

BoxDecoration primaryCircle = BoxDecoration(
  shape: BoxShape.circle,
  color: ColorsApp.primaryColor,
);

BoxDecoration borderBottomRightTopLeftprimary = BoxDecoration(
  color: ColorsApp.primaryColor,
  borderRadius: BorderRadius.only(
    bottomRight: Radius.circular(25),
    topLeft: Radius.circular(25),
  ),
);

/**
 *   
 */
