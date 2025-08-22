import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/app_router.dart';
import 'package:myproject/components/themeData/constant.dart';
import 'package:myproject/components/themeData/theme_app.dart';
import 'package:myproject/features/splash/view/screen/splash_screen.dart';

class MyAppView extends StatelessWidget {
  final AppRouter appRouter;
  const MyAppView({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(320, 860),
      minTextAdapt: true,
      child: MaterialApp(
        theme: themeApp,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localizationDelegates,
        supportedLocales: supportedLocales,
        onGenerateRoute: appRouter.generateRoute,
        //initialRoute: Routes.loading,
        home: SplashScreen(),
      ),
    );
  }
}