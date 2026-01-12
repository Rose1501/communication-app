import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/extension.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/themeData/routes_app.dart';

class ArchivedCurriculaButton extends StatelessWidget {
  final String teacherId;
  final String teacherName;

  const ArchivedCurriculaButton({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToArchivedCurricula(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsApp.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'المناهج المؤرشفة',
              style: font15White.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToArchivedCurricula(BuildContext context) {
    context.pushNamed(Routes.archivedCurricula , arguments: {
      'teacherId': teacherId,
      'teacherName': teacherName,
    });
  }
}