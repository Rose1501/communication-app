import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/size_box.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/data_management/bloc/semester_courses/semester_courses_bloc.dart';
import 'package:myproject/features/data_management/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:myproject/features/data_management/view/widgets/course_edit_screen.dart';
import 'package:semester_repository/semester_repository.dart';

class SemesterCoursesList extends StatelessWidget {
  final List<CoursesModel> courses;
  final bool isLoading;

  const SemesterCoursesList({
    super.key,
    required this.courses,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (courses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SemesterCoursesBloc>().add(const RefreshSemesterCourses());
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return SemesterCourseCard(course: courses[index]);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsApp.primaryColor),
          getHeight(16),
          Text('جاري تحميل المواد...', style: font16black),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 400.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 64.sp, color: Colors.grey[400]),
              getHeight(16),
              Text(
                'لا توجد مواد في هذا الفصل',
                style: font18blackbold.copyWith(color: Colors.grey[600]),
              ),
              getHeight(8),
              Text(
                'انتقل إلى قسم "المواد المتاحة" لإضافة مواد',
                style: font14grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SemesterCourseCard extends StatelessWidget {
  final CoursesModel course;

  const SemesterCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
  elevation: 2,
  margin: EdgeInsets.only(bottom: 12.h),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: InkWell(
    onTap: () => _showEditScreen(context, course),
    borderRadius: BorderRadius.circular(12),
    splashColor: ColorsApp.primaryColor.withOpacity(0.1), // ✅ تأثير النقر
    highlightColor: ColorsApp.primaryColor.withOpacity(0.05), // ✅ تأثير التحديد
    child: Container(
      padding: EdgeInsets.all(16.r),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: ColorsApp.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorsApp.primaryColor),
                  ),
                  child: Icon(Icons.menu_book, 
                      color: ColorsApp.primaryColor, size: 20.sp),
                ),
                getWidth(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: font16blackbold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      getHeight(4),
                      Text(
                        course.codeCs,
                        style: font14grey,
                      ),
                    ],
                  ),
                ),
                // ✅ زر الحذف
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                  onPressed: () => _showDeleteDialog(context, course),
                ),
              ],
            ),
            getHeight(12),
            Row(
              children: [
                _buildInfoItem(Icons.people, '${course.numOfStudent} طالب'),
                getWidth(16),
                _buildInfoItem(Icons.person, course.president),
              ],
            ),
            getHeight(8),
            if (course.groups.isNotEmpty) ...[
              Text(
                'المجموعات: ${course.groups.length}',
                style: font12Grey,
              ),
            ],
            SizedBox(height: 8.h),
            
          ],
        ),
      ),
    ),
  );
}

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey),
        getWidth(4),
        Text(text, style: font12Grey),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, CoursesModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المادة', style: font16blackbold),
        content: Text('هل أنت متأكد من حذف المادة "${course.name}" من الفصل؟', style: font14black),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: font14black),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SemesterCoursesBloc>().add(RemoveCourseFromSemester(course.id));
            },
            child: Text('حذف', style: font14Error),
          ),
        ],
      ),
    );
  }

  void _showEditScreen(BuildContext context, CoursesModel course) {
    final semesterId = context.read<SemesterCoursesBloc>().state.currentSemester?.id ?? '';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<SemesterCoursesBloc>()),
            BlocProvider.value(value: context.read<UserManagementBloc>()),
          ],
          child: CourseEditScreen(
            semesterId: semesterId,
            course: course,
          ),
        ),
      ),
    );
  }
}