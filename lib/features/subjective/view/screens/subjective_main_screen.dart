import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/home/bloc/my_user_bloc/my_user_bloc.dart';
import 'package:myproject/features/home/view/widget/bottom_navigation_bar.dart';
import 'package:myproject/features/subjective/view/screens/doctor_groups_screen.dart';
import 'package:myproject/features/subjective/view/screens/student_groups_screen.dart';

class SubjectiveMainScreen extends StatefulWidget {
  const SubjectiveMainScreen({super.key});

  @override
  State<SubjectiveMainScreen> createState() => _SubjectiveMainScreenState();
}

class _SubjectiveMainScreenState extends State<SubjectiveMainScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    navigateToScreen(index, getUserRole(context), context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, myUserState) {
        if (myUserState.status != MyUserStatus.success || myUserState.user == null) {
          return Scaffold(
            appBar: const CustomAppBarTitle(title: 'المقررات الدراسية'),
            body: Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor)),
          );
        }

        final user = myUserState.user!;

        return  Scaffold(
          appBar: const CustomAppBarTitle(title: 'المقررات الدراسية'),
          body:  _buildRoleBasedContent(getUserRole(context), user.userID,user.name),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            userRole: getUserRole(context),
          ),
        );
      },
    );
  }

  Widget _buildRoleBasedContent(String userRole, String userId,String username) {
    switch (userRole) {
      case 'Doctor':
        return DoctorGroupsScreen(doctorId: userId);
      case 'Student':
        return StudentGroupsScreen(studentId: userId , studentname:username);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: ColorsApp.red),
              const SizedBox(height: 16),
              Text(
                'غير مسموح بالوصول',
                style: font20blackbold,
              ),
              const SizedBox(height: 8),
              Text(
                'هذه الصفحة متاحة فقط للطلاب والأساتذة',
                style: font16Grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }
}