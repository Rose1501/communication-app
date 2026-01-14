import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/app_router.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/theme_app.dart';
import 'package:myproject/features/home/view/screen/home_screen.dart';
import 'package:myproject/features/login/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:myproject/features/onboarding/view/screen/onboarding_screen.dart';
import 'package:myproject/features/splash/view/screen/splash_screen.dart';

class MyAppView extends StatelessWidget {
  final AppRouter appRouter;
  const MyAppView({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(320, 860),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          theme: themeApp,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: localizationDelegates,
          supportedLocales: supportedLocales,
          onGenerateRoute: appRouter.generateRoute,
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              debugPrint('🏠 Building home with status: ${state.status}, isFirstLaunch: ${state.isFirstLaunch}');
              // إذا كان التشغيل الأول، اعرض SplashScreen
              if (state.isFirstLaunch) {
                debugPrint('🎬 Showing SplashScreen');
                return SplashScreen();
              }
              // خلاف ذلك، اعرض الشاشة المناسبة بناءً على حالة المصادقة
              else  if (state.status == AuthenticationStatus.authenticated) {
                debugPrint('🏠 Showing HomeScreen');
                return const HomeScreen();
              } else if (state.status == AuthenticationStatus.unauthenticated) {
                debugPrint('👋 Showing OnboardingScreen');
                return const OnboardingScreen();
              } else {
                debugPrint('🎬 Default SplashScreen');
                return SplashScreen();
              }
            },
          ),
        );
      },
    );
  }
}
