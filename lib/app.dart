import 'package:chat_repository/chat_repository.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:course_repository/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:myproject/app_router.dart';
import 'package:myproject/app_view.dart';
import 'package:myproject/features/chat/bloc/chat_bloc.dart';
import 'package:myproject/features/complaints/bloc/complaint_bloc.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:myproject/features/forget_password/bloc/auth_bloc.dart';
import 'package:myproject/features/graduation_project/bloc/project_bloc/project_bloc.dart';
import 'package:myproject/features/graduation_project/bloc/user/user_bloc.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/bloc/post_bloc/advertisement_bloc.dart';
import 'package:myproject/features/notifications/bloc/notifications_bloc.dart';
import 'package:myproject/features/profile/bloc/teacher_data_bloc/teacher_data_bloc.dart';
import 'package:myproject/features/profile/bloc/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:myproject/features/login/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:myproject/features/manager/bloc/advertisement_form_bloc.dart';
import 'package:myproject/features/request/bloc/request_bloc.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:myproject/services/notification_service.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:request_repository/request_repository.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:advertisement_repository/advertisement_repository.dart';

class MainApp extends StatelessWidget {
  final UserRepository userRepository;
  final AdvertisementRepository advertisementRepository;
  final NotificationsRepository notificationsRepository;
  final NotificationService notificationService;

  const MainApp({
    super.key, 
    required this.userRepository,
    required this.advertisementRepository,
    required this.notificationsRepository,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [//
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: advertisementRepository),
        RepositoryProvider.value(value: notificationsRepository),
        RepositoryProvider.value(value: notificationService),
        RepositoryProvider.value(value: FirebaseRequestRepository(notificationsRepository: notificationsRepository,)),
        RepositoryProvider.value(value: FirebaseComplaintRepository(notificationsRepository: notificationsRepository,)),
        RepositoryProvider.value(value: FirebaseSemesterRepository),
        RepositoryProvider.value(value: FirebaseCourseRepository),
        RepositoryProvider.value(value: FirebaseSubjectiveRepository(
            semesterRepository: FirebaseSemesterRepository(),notificationsRepository: notificationsRepository,)),
        RepositoryProvider.value(value: FirebaseTeacherDataRepository()),
        RepositoryProvider.value(value: FirebaseChatRepository(userRepository,FirebaseSemesterRepository())),
        RepositoryProvider(create: (context) => FirebaseProjectRepository()),
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
          BlocProvider<DataManagementBloc>(
            create: (context) => DataManagementBloc(
            courseRepository: FirebaseCourseRepository(),
            semesterRepository: FirebaseSemesterRepository(),
            ),
          ),
          BlocProvider<UserManagementBloc>(
            create: (context) => UserManagementBloc(
            userRepository: userRepository,
            ),
          ),
          BlocProvider<SemesterCoursesBloc>(
            create: (context) => SemesterCoursesBloc(
            semesterRepository: FirebaseSemesterRepository(),
            courseRepository: FirebaseCourseRepository(),
            ),
          ),
          BlocProvider<SubjectiveBloc>(
            create: (context) => SubjectiveBloc(
            subjectiveRepository: FirebaseSubjectiveRepository(
            semesterRepository: FirebaseSemesterRepository(), 
              ),
            )..add(InitializeCurrentSemesterEvent()),
          ),
          BlocProvider<TeacherDataBloc>(
            create: (context) => TeacherDataBloc(
            teacherDataRepository: FirebaseTeacherDataRepository(),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
            chatRepository: FirebaseChatRepository(userRepository,FirebaseSemesterRepository()),
            ),
          ),
          BlocProvider(
            create: (context) => NotificationsBloc(
              repository: context.read<NotificationsRepository>(),
              notificationService: context.read<NotificationService>(),
            ),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              userRepository: userRepository,
            )
          ),
          BlocProvider(
            create: (context) => ProjectBloc(
              projectRepository: FirebaseProjectRepository(),
            )
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