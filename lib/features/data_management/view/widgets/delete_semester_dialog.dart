import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/data_management/bloc/data_management_bloc/data_management_bloc.dart';
import 'package:semester_repository/semester_repository.dart';

/*
 * 🗑️ نافذة تأكيد حذف الفصل الدراسي
 * 
 * الوظائف:
 * ✅ عرض تحذير قبل الحذف
 * ✅ تأكيد الحذف
 * ✅ إلغاء العملية
 */

class DeleteSemesterDialog extends StatelessWidget {
  final SemesterModel semester;

  const DeleteSemesterDialog({super.key, required this.semester});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('حذف الفصل الدراسي', style: font16blackbold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('هل أنت متأكد من حذف الفصل الدراسي التالي؟', style: font14black),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${semester.typeSemester}', style: font14black.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text('${_formatDate(semester.startTime)} - ${_formatDate(semester.endTime)}', style: font12Grey),
                SizedBox(height: 4.h),
                Text('${semester.minCredits}-${semester.maxCredits} ساعة معتمدة', style: font12Grey),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '⚠️ تحذير: سيتم حذف جميع المواد والطلاب المرتبطين بهذا الفصل!',
            style: font12Grey.copyWith(color: Colors.orange),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: font14black),
        ),
        TextButton(
          onPressed: () {
            context.read<DataManagementBloc>().add(DeleteSemester(semester.id));
            Navigator.pop(context);
          },
          child: Text('حذف', style: font14Error),
        ),
      ],
    );
  }

  /// 📅 تنسيق التاريخ للنص
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}