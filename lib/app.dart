import 'package:flutter/material.dart';
import 'package:myproject/app_router.dart';
import 'package:myproject/app_view.dart';
import 'package:myproject/features/login/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainApp extends StatelessWidget {
  final UserRepository userRepository;
  const MainApp({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => userRepository,
      child: BlocProvider(
        create: (context) =>AuthenticationBloc(
          myUserRepository: context.read<UserRepository>(),
        ),
        child: MyAppView(appRouter: AppRouter(userRepository: userRepository)),
      ),
    );
  }
}
