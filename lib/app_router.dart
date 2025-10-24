import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/widget/infoAPP.dart';
import 'package:myproject/features/complaints/view/screens/complaints_list_screen.dart';
import 'package:myproject/features/forget_password/view/screen/forget_password.dart';
import 'package:myproject/features/forget_password/view/screen/recovery_password.dart';
import 'package:myproject/features/home/view/screen/home_screen.dart';
import 'package:myproject/features/login/bloc/login_bloc/login_bloc.dart';
import 'package:myproject/features/login/view/screen/login_screen.dart';
import 'package:myproject/features/onboarding/view/screen/onboarding_screen.dart';
import 'package:myproject/features/request/view/screen/display_request_student.dart';
import 'package:myproject/features/request/view/screen/reply_request.dart';
import 'package:myproject/features/request/view/screen/send_request.dart';
import 'package:myproject/features/signup/bloc/signup_bloc.dart';
import 'package:myproject/features/signup/view/screen/signup_screen.dart';
import 'package:myproject/features/splash/view/screen/splash_screen.dart';
import 'package:user_repository/user_repository.dart';

class AppRouter {
  final UserRepository userRepository;
  final AdvertisementRepository advertisementRepository;
  AppRouter({required this.userRepository, required this.advertisementRepository});
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

        case Routes.about:
            return MaterialPageRoute(builder: (_) =>  Info());

        case Routes.displayRequest:
        return MaterialPageRoute(builder: (_) => const DisplayRequestStudent());

      case Routes.replyRequest:
        return MaterialPageRoute(builder: (_) => const ReplyRequest());

      case Routes.sendRequest:
        return MaterialPageRoute(builder: (_) => const SendRequest(),);

      case Routes.complaintsList:
        return MaterialPageRoute( builder: (_) => const ComplaintsListScreen(),);



          default:
            return MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    body: Center(child: Text('الصفحة غير موجودة:${settings.name}')),
                  ),
            );
        }
  }
}
