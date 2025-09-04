import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/app_router.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/theme_app.dart';
import 'package:myproject/features/home/home.dart';
import 'package:myproject/features/login/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:myproject/features/login/bloc/login_bloc/login_bloc.dart';
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
              if (state.status == AuthenticationStatus.authenticated) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create:
                          (context) => LoginBloc(
                            userRepository:
                                context
                                    .read<AuthenticationBloc>()
                                    .userRepository,
                          ),
                    ),
                  ],
                  child: const HomeScreen(),
                );
              } else if (state.status == AuthenticationStatus.unauthenticated) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create:
                          (context) => LoginBloc(
                            userRepository:
                                context
                                    .read<AuthenticationBloc>()
                                    .userRepository,
                          ),
                    ),
                  ],
                  child: const OnboardingScreen(),
                );
              } else {
                return SplashScreen();
              }
            },
          ),
        );
      },
    );
  }
}
