import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/profile/bloc/teacher_data_bloc/teacher_data_bloc.dart';
import 'package:myproject/features/profile/view/widget/archived_curricula_button.dart';
import 'package:myproject/features/profile/view/widget/user_profile_image_section.dart';
import 'package:myproject/features/profile/view/widget/user_profile_info_section.dart';
import 'package:myproject/features/profile/view/widget/user_profile_officeHours_section.dart';
import 'package:myproject/features/profile/view/widget/user_profile_password_section.dart';
import 'package:myproject/features/profile/view/widget/user_profile_teaching_courses_section.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileContent extends StatelessWidget {
  final UserModels userModel;
  final bool isEditingPassword;
  final bool isChangingImage;
  final bool isResetMode;
  final bool isEditingOfficeHours;
  final bool isEditingCourses;
  final String? selectedImagePath;
  final List<CoursesModel> selectedCourses;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController resetCodeController;
  final VoidCallback onToggleEditPasswordMode;
  final VoidCallback onToggleEditOfficeHoursMode;
  final VoidCallback onToggleEditCoursesMode;
  final VoidCallback onChangeImage;
  final VoidCallback onLogout;
  final VoidCallback onSendResetCode;
  final VoidCallback onVerifyResetCode;
  final VoidCallback onChangePassword;
  final VoidCallback onResetPasswordWithCode;
  final VoidCallback onSwitchToNormalMode;
  final VoidCallback onSwitchToResetMode;
  final VoidCallback onSaveOfficeHours;
  final VoidCallback onSaveTeachingCourses;
  final VoidCallback onDeleteAllTeachingCourses; 
  final VoidCallback onLoadTeachingCourses;
  final Function(List<CoursesModel>) onUpdateSelectedCourses; 
  final Future<void> Function() onRefresh;
  final TeacherDataBloc? teacherDataBloc;
  final SemesterRepository? semesterRepository;

  const UserProfileContent({
    super.key,
    required this.userModel,
    required this.isEditingPassword,
    required this.isChangingImage,
    required this.isResetMode,
    required this.isEditingOfficeHours,
    required this.isEditingCourses,
    required this.selectedImagePath,
    required this.selectedCourses,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.resetCodeController,
    required this.onToggleEditPasswordMode,
    required this.onToggleEditOfficeHoursMode,
    required this.onToggleEditCoursesMode,
    required this.onChangeImage,
    required this.onLogout,
    required this.onSendResetCode,
    required this.onVerifyResetCode,
    required this.onChangePassword,
    required this.onResetPasswordWithCode,
    required this.onSwitchToNormalMode,
    required this.onSwitchToResetMode,
    required this.onSaveOfficeHours,
    required this.onSaveTeachingCourses,
    required this.onDeleteAllTeachingCourses, 
    required this.onLoadTeachingCourses,
    required this.onUpdateSelectedCourses,
    required this.onRefresh,
    this.teacherDataBloc,
    this.semesterRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(title: 'الملف الشخصي'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // قسم صورة المستخدم
            UserProfileImageSection(
              userModel: userModel,
              selectedImagePath: selectedImagePath,
              isChangingImage: isChangingImage,
              onChangeImage: onChangeImage,
            ),
            getHeight(24.h),
            
            // قسم معلومات المستخدم
            UserProfileInfoSection(userModel: userModel),
            getHeight(16.h),
            
            // زر المناهج المؤرشفة (فقط للأساتذة)
            if (userModel.role == 'Doctor' || userModel.role == 'doctor')
              Column(
                children: [
                  ArchivedCurriculaButton(
                    teacherId: userModel.userID,
                    teacherName: userModel.name,
                  ),
                  getHeight(16.h),
                ],
              ),
            
            // قسم الساعات المكتبية (فقط للأساتذة)
            if (userModel.role == 'Doctor' || userModel.role == 'doctor' ||userModel.role == 'Admin' || userModel.role == 'admin')
              Column(
                children: [
                  _buildOfficeHoursSection(),
                  getHeight(16.h),
                ],
              ),
            
            // قسم المواد الدراسية (فقط للأساتذة)
            if (userModel.role == 'Doctor' || userModel.role == 'doctor')
              Column(
                children: [
                  _buildTeachingCoursesSection(),
                  getHeight(16.h),
                ],
              ),
            
            // قسم كلمة المرور
            _buildPasswordSection(),
            
            getHeight(16.h),
            // زر تسجيل الخروج
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeHoursSection() {
    if (isEditingOfficeHours) {
      return UserProfileOfficeHoursSection(
        teacherId: userModel.userID,
        teacherName: userModel.name,
        onSave: onSaveOfficeHours,
        onCancel: onToggleEditOfficeHoursMode,
      );
    } else {
      return ElevatedButton(
        onPressed: onToggleEditOfficeHoursMode,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsApp.primaryColor,
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('الساعات المكتبية', style: font15White),
          ],
        ),
      );
    }
  }

  Widget _buildTeachingCoursesSection() {
    if (isEditingCourses) {
      return UserProfileTeachingCoursesSection(
        teacherId: userModel.userID,
        teacherName: userModel.name,
        selectedCourses: selectedCourses,
        onUpdateSelectedCourses: onUpdateSelectedCourses,
        onSave: onSaveTeachingCourses,
        onDeleteAll: onDeleteAllTeachingCourses, // تمرير الدالة هنا
        onLoad: onLoadTeachingCourses,
        onCancel: onToggleEditCoursesMode,
      );
    } else {
      return ElevatedButton(
        onPressed: onToggleEditCoursesMode,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsApp.primaryColor,
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('المواد الدراسية', style: font15White),
          ],
        ),
      );
    }
  }

  Widget _buildPasswordSection() {
    if (isEditingPassword) {
      return UserProfilePasswordSection(
        currentPasswordController: currentPasswordController,
        newPasswordController: newPasswordController,
        confirmPasswordController: confirmPasswordController,
        resetCodeController: resetCodeController,
        onSendResetCode: onSendResetCode,
        onVerifyResetCode: onVerifyResetCode,
        onChangePassword: onChangePassword,
        onResetPasswordWithCode: onResetPasswordWithCode,
        onCancel: onToggleEditPasswordMode,
        isResetMode: isResetMode,
        onSwitchToNormalMode: onSwitchToNormalMode,
        onSwitchToResetMode: onSwitchToResetMode,
      );
    } else {
      return ElevatedButton(
        onPressed: onToggleEditPasswordMode,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsApp.primaryColor,
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text('تغيير كلمة المرور', style: font15White),
      );
    }
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: onLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, size: 20.w, color: Colors.white),
          SizedBox(width: 8.w),
          Text('تسجيل الخروج', style: font15White),
        ],
      ),
    );
  }
}