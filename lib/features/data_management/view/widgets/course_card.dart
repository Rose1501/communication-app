
import 'package:course_repository/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/box_decoration.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/edit_course_dialog.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: dataManagementCardDecoration,
      child: Row(
        children: [
          // رمز المادة
          Container(
            width: 50.w,
            height: 50.h,
            decoration: primaryCircle,
            child: Icon(Icons.school, color: ColorsApp.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          // معلومات المادة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name.isNotEmpty ? course.name : 'مادة غير محددة',
                  style: font16blackbold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  course.codeCs.isNotEmpty ? course.codeCs : 'غير محدد', 
                  style: font14grey,
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 16.w,
                  runSpacing: 4.h,
                  children: [
                    _buildInfoItem(Icons.credit_card, '${course.credits} ساعة معتمدة'),
                    _buildPrerequisitesInfo()
                  ],
                ),
              ],
            ),
          ),
          // زر الإجراءات
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل')),
              const PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
        ],
      ),
    );
  }

  // تحديث عرض المتطلبات
Widget _buildPrerequisitesInfo() {
  if (course.requestCourses.isEmpty) {
    return _buildInfoItem(Icons.list, 'لا يوجد متطلبات');
  }
  
  // ✅ عرض عدد المتطلبات وأكوادها
  final prerequisitesCount = course.requestCourses.length;
  final prerequisitesText = course.requestCourses.join(', ');
  
  return Tooltip(
    message: prerequisitesText,
    child: _buildInfoItem(Icons.list, '$prerequisitesCount  متطلب'),
  );
}

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'edit':
        _showEditCourseDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showEditCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditCourseDialog(course: course),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المادة'),
        content: Text('هل أنت متأكد من حذف المادة ${course.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<DataManagementBloc>().add(DeleteCourse(course.id));
              Navigator.pop(context);
            },
            child: Text('حذف', style: font14Error),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
        constraints: BoxConstraints(maxWidth: 120.w), // منع التجاوز
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(icon, size: 14.sp, color: Colors.grey),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                text,
                style: font12Grey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
  }
}