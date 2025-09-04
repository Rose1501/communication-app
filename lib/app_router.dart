import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/features/forget_password/view/screen/forget_password.dart';
import 'package:myproject/features/forget_password/view/screen/recovery_password.dart';
import 'package:myproject/features/home/home.dart';
import 'package:myproject/features/login/bloc/login_bloc/login_bloc.dart';
import 'package:myproject/features/login/view/screen/login_screen.dart';
import 'package:myproject/features/onboarding/view/screen/onboarding_screen.dart';
import 'package:myproject/features/signup/bloc/signup_bloc.dart';
import 'package:myproject/features/signup/view/screen/signup_screen.dart';
import 'package:myproject/features/splash/view/screen/splash_screen.dart';
import 'package:user_repository/user_repository.dart';

class AppRouter {
  final UserRepository userRepository;
  AppRouter({required this.userRepository});
  MaterialPageRoute generateRoute(RouteSettings settings) {
        switch (settings.name) {
          case Routes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());

          case Routes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());

          case Routes.login:
            return MaterialPageRoute(
              builder: (_) => BlocProvider(
            create: (context) => LoginBloc(userRepository: userRepository),
            child: const LoginScreen(),
          ),);

          case Routes.signup:
            return MaterialPageRoute(builder: (_) =>  BlocProvider(
              create: (context) => SignUpBloc(userRepository: userRepository),
              child: const Signupscreen(),
            ));

          case Routes.forgetPassword:
            return MaterialPageRoute(builder: (_) => const ForgetPassword());

          case Routes.recoveryPassword:
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => RecoveryPassword(email: email),
            );

          case Routes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          default:
            return MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    body: Center(child: Text('اين النص:${settings.name}')),
                  ),
            );
        }
  }
}
