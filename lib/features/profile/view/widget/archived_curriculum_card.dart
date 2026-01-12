import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';

class ArchivedCurriculumCard extends StatelessWidget {
  final ArchivedCurriculumModel curriculum;
  final VoidCallback onDelete;
  final VoidCallback onOpenFile;

  const ArchivedCurriculumCard({
    super.key,
    required this.curriculum,
    required this.onDelete,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صف العنوان والأزرار
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curriculum.courseName,
                        style: font16blackbold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(curriculum.archivedAt),
                            style: font12Grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, color: Colors.red, size: 22.w),
                  tooltip: 'حذف',
                ),
              ],
            ),

            // وصف الأرشفة (إذا كان موجوداً)
            if (curriculum.archiveDescription != null && curriculum.archiveDescription!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'الوصف: ${curriculum.archiveDescription!}',
                  style: font14black.copyWith(color: Colors.grey[700]),
                ),
              ),

            // زر فتح الملف
            if (curriculum.fileUrl.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: ElevatedButton.icon(
                  onPressed: onOpenFile,
                  icon: const Icon(Icons.file_open, color: Colors.white, size: 20),
                  label: const Text('فتح الملف', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.primaryColor,
                    minimumSize: Size(double.infinity, 45.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return 'تم الأرشفة في: $day/$month/$year - $hour:$minute';
  }
}