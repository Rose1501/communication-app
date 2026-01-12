import 'package:flutter/material.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:subjective_repository/subjective_repository.dart';

class AddEditLectureDialog extends StatelessWidget {
  final AttendanceRecordModel? lecture;
  final String groupName;

  const AddEditLectureDialog({
    super.key,
    this.lecture,
    required this.groupName,
  });

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.primaryColor,
            ),
            child: Text('موافق', style: font13White),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = lecture != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit : Icons.add, color: ColorsApp.primaryColor),
          const SizedBox(width: 8),
          Text(isEdit ? 'تعديل المحاضرة' : 'إضافة محاضرة جديدة'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المجموعة: $groupName', style: font14black.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          if (isEdit) ...[
            _buildInfoItem('عنوان المحاضرة:', lecture!.lectureTitle),
            _buildInfoItem('التاريخ:', _formatDate(lecture!.date)),
            const SizedBox(height: 12),
            
            // إحصاءات
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('الحضور', lecture!.presentStudentIds.length.toString(), Icons.check),
                      _buildStatItem('الغياب', lecture!.absentStudentIds.length.toString(), Icons.close),
                      _buildStatItem('ملاحظات', lecture!.studentNotes.length.toString(), Icons.note),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مجموع الطلاب: ${lecture!.presentStudentIds.length + lecture!.absentStudentIds.length}',
                    style: font12black.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Text('سيتم نقلك إلى شاشة إدارة الحضور لتعديل هذه المحاضرة.', 
                style: font12black),
          ] else ...[
            Text('سيتم نقلك إلى شاشة إدارة الحضور لإضافة محاضرة جديدة.', 
                style: font12black),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (isEdit) {
              final confirmed = await _showConfirmationDialog(
                context,
                'تعديل المحاضرة',
                'هل تريد تعديل محاضرة "${lecture!.lectureTitle}"؟',
              );
              if (confirmed) {
                Navigator.pop(context, lecture); // إرجاع المحاضرة للتعديل
              }
            } else {
              Navigator.pop(context, true); // إرجاع true للإضافة الجديدة
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsApp.primaryColor,
          ),
          child: Text(isEdit ? 'تعديل' : 'إضافة', style: font13White),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: font12black.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: font12black)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: ColorsApp.primaryColor),
        const SizedBox(height: 2),
        Text(value, style: font12black.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: font10Grey),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final days = [
      'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
    ];
    final dayName = days[date.weekday % 7];
    return '$dayName ${date.year}/${date.month}/${date.day}';
  }
}