import 'package:flutter/material.dart';
import 'package:myproject/app_router.dart';
import 'package:myproject/app_view.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MyAppView(appRouter: AppRouter());
  }
}