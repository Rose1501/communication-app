import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:course_repository/course_repository.dart';
import 'package:myproject/features/data_management/view/widgets/course_card.dart';

class CoursesList extends StatelessWidget {
  final List<CourseModel> courses;

  const CoursesList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: CourseCard(course: courses[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 400.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 64.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text(
                'لا توجد مواد',
                style: font18blackbold.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Text(
                'انقر على زر الإضافة لإنشاء مادة جديدة',
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