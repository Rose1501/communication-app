import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/features/forget_password/view/screen/forget_password.dart';
import 'package:myproject/features/login/view/screen/login_screen.dart';
import 'package:myproject/features/onboarding/view/screen/onboarding_screen.dart';
import 'package:myproject/features/signup/view/screen/signup_screen.dart';
import 'package:myproject/features/splash/view/screen/splash_screen.dart';

class AppRouter {
  MaterialPageRoute generateRoute(RouteSettings settinges) {
    switch (settinges.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const Signupscreen());
        
      case Routes.forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPassword());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('اين النص:${settinges.name}')),
              ),
        );
    }
  }
}
