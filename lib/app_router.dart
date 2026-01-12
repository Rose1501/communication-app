import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:myproject/components/themeData/routes_app.dart';
import 'package:myproject/components/widget/infoAPP.dart';
import 'package:myproject/features/chat/view/screens/chat_home_screen.dart';
import 'package:myproject/features/chat/view/screens/doctors_chat_screen.dart';
import 'package:myproject/features/chat/view/screens/group_chat_screen.dart';
import 'package:myproject/features/chat/view/screens/private_chat_screen.dart';
import 'package:myproject/features/chat/view/screens/user_search_screen.dart';
import 'package:myproject/features/complaints/view/screens/complaints_list_screen.dart';
import 'package:myproject/features/data_management/view/screens/courses_management_screen.dart';
import 'package:myproject/features/data_management/view/screens/data_management_screen.dart';
import 'package:myproject/features/data_management/view/screens/semester_courses_screen.dart';
import 'package:myproject/features/data_management/view/screens/semesters_management_screen.dart';
import 'package:myproject/features/forget_password/view/screen/forget_password.dart';
import 'package:myproject/features/forget_password/view/screen/recovery_password.dart';
import 'package:myproject/features/graduation_project/view/screen/project_details_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/project_management_dashboard_screen.dart';
import 'package:myproject/features/graduation_project/view/screen/task_submissions_screen.dart';
import 'package:myproject/features/home/view/screen/home_screen.dart';
import 'package:myproject/features/login/bloc/login_bloc/login_bloc.dart';
import 'package:myproject/features/login/view/screen/login_screen.dart';
import 'package:myproject/features/notifications/view/screens/notifications_list_screen.dart';
import 'package:myproject/features/onboarding/view/screen/onboarding_screen.dart';
import 'package:myproject/features/profile/view/screen/archived_curricula_screen.dart';
import 'package:myproject/features/request/view/screen/display_request_student.dart';
import 'package:myproject/features/request/view/screen/reply_request.dart';
import 'package:myproject/features/request/view/screen/send_request.dart';
import 'package:myproject/features/signup/bloc/signup_bloc.dart';
import 'package:myproject/features/signup/view/screen/signup_screen.dart';
import 'package:myproject/features/splash/view/screen/splash_screen.dart';
import 'package:myproject/features/subjective/view/screens/advertisements_screen.dart';
import 'package:myproject/features/subjective/view/screens/assignments_screen.dart';
import 'package:myproject/features/subjective/view/screens/curriculum_screen.dart';
import 'package:myproject/features/subjective/view/screens/doctor_groups_screen.dart';
import 'package:myproject/features/subjective/view/screens/group_content_screen.dart';
import 'package:myproject/features/subjective/view/screens/marks_screen.dart';
import 'package:myproject/features/subjective/view/screens/student_groups_screen.dart';
import 'package:myproject/features/subjective/view/screens/subjective_main_screen.dart';
import 'package:semester_repository/semester_repository.dart';
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

          case Routes.archivedCurricula:
            final arguments = settings.arguments as Map<String, dynamic>?;
            final teacherId = arguments?['teacherId'] as String? ?? '';
            final teacherName = arguments?['teacherName'] as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => ArchivedCurriculaScreen  (
                teacherId: teacherId,
                teacherName: teacherName,
              ),
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

          case Routes.dataManagement:
            return MaterialPageRoute(builder: (_) => const DataManagementScreen());

          case Routes.coursesManagement:
            return MaterialPageRoute(builder: (_) => const CoursesManagementScreen());

          case Routes.semestersManagement:
            return MaterialPageRoute(builder: (_) => const SemestersManagementScreen());

          case Routes.semesterCourses:
            return MaterialPageRoute(builder: (_) =>  const SemesterCoursesScreen());

          case Routes.subjectiveMain:
        return MaterialPageRoute(builder: (_) => const SubjectiveMainScreen());

      case Routes.doctorGroups:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final doctorId = arguments?['doctorId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => DoctorGroupsScreen(doctorId: doctorId),
        );

      case Routes.studentGroups:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final studentId = arguments?['studentId'] as String? ?? '';
        final studentname = arguments?['studentname'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => StudentGroupsScreen(studentId: studentId,studentname: studentname,),
        );

      case Routes.groupContent:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final course = arguments?['course'] as CoursesModel?;
        final group = arguments?['group']as GroupModel?;
        final userRole = arguments?['userRole'] as String? ?? '';
        final userId = arguments?['userId'] as String? ?? '';
        final studentname = arguments?['studentname'] as String? ?? '';
        
        if (course == null || group == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('خطأ: بيانات المجموعة غير متوفرة')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => GroupContentScreen(
            course: course,
            group: group,
            userRole: userRole,
            userId: userId,
            studentname :studentname
          ),
        );

      case Routes.curriculum:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final course = arguments?['course'] as CoursesModel?;
        final group = arguments?['group']as GroupModel?;
        final userRole = arguments?['userRole'] as String? ?? '';
        final userId = arguments?['userId'] as String? ?? '';
        
        if (course == null || group == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('خطأ: بيانات المجموعة غير متوفرة')),
            ),
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => CurriculumScreen(
            course: course,
            group: group,
            userRole: userRole,
            userId: userId,
          ),
        );

      case Routes.assignments:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final course = arguments?['course'] as CoursesModel?;
        final group = arguments?['group']as GroupModel?;
        final userRole = arguments?['userRole'] as String? ?? '';
        final userId = arguments?['userId'] as String? ?? '';
        final studentname = arguments?['studentname'] as String? ?? '';
        
        if (course == null || group == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('خطأ: بيانات المجموعة غير متوفرة')),
            ),
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => AssignmentsScreen(
            course: course,
            group: group,
            userRole: userRole,
            userId: userId,
            studentname:studentname
          ),
        );

      case Routes.advertisements:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final course = arguments?['course'] as CoursesModel?;
        final group = arguments?['group']as GroupModel?;
        final userRole = arguments?['userRole'] as String? ?? '';
        final userId = arguments?['userId'] as String? ?? '';
        
        if (course == null || group == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('خطأ: بيانات المجموعة غير متوفرة')),
            ),
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => AdvertisementsScreen(
            course: course,
            group: group,
            userRole: userRole,
            userId: userId,
          ),
        );

      case Routes.marks:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final course = arguments?['course'] as CoursesModel?;
        final group = arguments?['group']as GroupModel?;
        final userRole = arguments?['userRole'] as String? ?? '';
        final userId = arguments?['userId'] as String? ?? '';
        
        if (course == null || group == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('خطأ: بيانات المجموعة غير متوفرة')),
            ),
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => MarksScreen(
            course: course,
            group: group,
            userRole: userRole,
            userId: userId,
          ),
        );

      case Routes.notificationsList:
        return MaterialPageRoute(builder: (_) => const NotificationsListScreen());

      case Routes.groupchat:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final userId = arguments?['userId']as String? ?? '';;
        final groupId = arguments?['groupId']as String? ?? '';;
        final title = arguments?['title'] as String? ?? 'دردشة المجموعة';
        final groupModel = arguments?['groupModel'] as GroupModel?;
        final course = arguments?['course'] as CoursesModel?;
        final userRole = arguments?['userRole'] as String? ?? 'Student';
        
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(
            userId: userId,
            groupId: groupId,
            title: title,
            course: course,
            groupModel: groupModel,
            userRole: userRole,
          ),
        );

      case Routes.chatHome:
        return MaterialPageRoute(builder: (_) => ChatHomeScreen());

        case Routes.userSearch:
            final arguments = settings.arguments as Map<String, dynamic>?;
            final userId = arguments?['userId'] as String? ?? '';
            final userRole = arguments?['userRole'] as String? ?? '';
        return MaterialPageRoute(
              builder: (_) => UserSearchScreen(currentUserId: userId, userRole: userRole),
        );

      case Routes.privateChat:
            final arguments = settings.arguments as Map<String, dynamic>? ?? {};
            // استخراج البيانات بأمان
            final userId = arguments['userId'] as String? ?? '';
            final receiverId = arguments['receiverId'] as String? ?? '';
            final title = arguments['title'] as String? ?? 'محادثة';
            
            return MaterialPageRoute(
              builder: (_) => PrivateChatScreen(
                userId: userId,
                receiverId: receiverId,
                title: title,
              ),
            );

      case Routes.doctorsChat:
            final arguments = settings.arguments as Map<String, dynamic>? ?? {};
            final userId = arguments['userId'] as String? ?? '';
            
            return MaterialPageRoute(
              builder: (_) => DoctorsChatScreen(
                userId: userId,
              ),
            );

      case Routes.projectManagementDashboard:
            return MaterialPageRoute(builder: (_) => const ProjectManagementDashboardScreen());

      case Routes.projectDetails:
            final arguments = settings.arguments as Map<String, dynamic>? ?? {};
            final projectSettings = arguments['projectSettings'] as ProjectSettingsModel?;
            final userRole = arguments['userRole'] as String? ?? '';
            
            if (projectSettings == null) {
              return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Center(child: Text('خطأ: بيانات المشروع غير متوفرة')),
                  ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => ProjectDetailsScreen(
                projectSettings: projectSettings,
                userRole: userRole,
              ),
            );

      case Routes.taskSubmission:
            final arguments = settings.arguments as Map<String, dynamic>? ?? {};
            final taskid = arguments['taskid'] as String;
            final taskTitle = arguments['title'] as String;
            if (taskid == null) {
              return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Center(child: Text('خطأ: بيانات المهمة غير متوفرة')),
                  ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => TaskSubmissionsScreen(
                taskId: taskid,
                taskTitle: taskTitle,
              ),
            );


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
