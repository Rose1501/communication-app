import 'package:complaint_repository/complaint_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/app_router.dart';
import 'package:myproject/app_view.dart';
import 'package:myproject/features/complaints/bloc/complaint_bloc.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:myproject/features/login/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';
import 'package:myproject/features/request/bloc/request_bloc.dart';
import 'package:request_repository/request_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:advertisement_repository/advertisement_repository.dart';

class MainApp extends StatelessWidget {
  final UserRepository userRepository;
  final AdvertisementRepository advertisementRepository;

  const MainApp({
    super.key, 
    required this.userRepository,
    required this.advertisementRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [//
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: advertisementRepository),
        RepositoryProvider.value(value: FirebaseRequestRepository),
        RepositoryProvider.value(value: FirebaseComplaintRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MyUserBloc(
              myUserRepository: userRepository,
            ),
          ),
          BlocProvider(
            create: (context) => AuthenticationBloc(
              myUserRepository: userRepository,
            ),
          ),
          BlocProvider(
            create: (context) => AdvertisementBloc(
              advertisementRepository: advertisementRepository,
              )
            ),
          BlocProvider(
            create: (context) => AdvertisementFormBloc(
              advertisementRepository: advertisementRepository,
            ),
          ),
          BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(userRepository: userRepository),
          ),
          BlocProvider(
            create: (context) => UpdateUserInfoBloc(
            userRepository: userRepository,
            ),
          ),
          BlocProvider( 
            create: (context) => RequestBloc(
              requestRepository: FirebaseRequestRepository(),
            ),
          ),
          BlocProvider(
            create: (context) => ComplaintBloc(
              complaintRepository: FirebaseComplaintRepository(),
            ),
          ),
        ],
        child: MyAppView(
          appRouter: AppRouter(
            userRepository: userRepository,
            advertisementRepository: advertisementRepository,
          ),
        ),
      ),
    );
  }
}