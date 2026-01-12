import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/custom_dialog.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class HomeworkSubmissionsScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final HomeworkModel homework;
  final String doctorId;

  const HomeworkSubmissionsScreen({
    super.key,
    required this.course,
    required this.group,
    required this.homework,
    required this.doctorId,
  });

  @override
  State<HomeworkSubmissionsScreen> createState() => _HomeworkSubmissionsScreenState();
}

class _HomeworkSubmissionsScreenState extends State<HomeworkSubmissionsScreen> {
  final Map<String, double> _gradingValues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTitle(
        title: 'تسليمات - ${widget.homework.title}',
      ),
      body: Column(
        children: [
          // إحصائيات سريعة
          _buildStatisticsCard(),
          const SizedBox(height: 16),
          // قائمة التسليمات
          Expanded(
            child: _buildSubmissionsList(),
          ),
        ],
      ),
      floatingActionButton: widget.homework.submittedCount > 0
          ? FloatingActionButton(
              onPressed: _saveAllGrades,
              backgroundColor: ColorsApp.green,
              child: const Icon(Icons.save, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildStatisticsCard() {
    final submittedCount = widget.homework.submittedCount;
    final totalStudents = widget.homework.totalStudents;
    final submissionRate = totalStudents == 0 
    ? '0' 
    : ((submittedCount / totalStudents * 100) == 0.0
        ? '0'
        : (submittedCount / totalStudents * 100).toStringAsFixed(1));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('المسلمين', '$submittedCount', Icons.assignment_turned_in),
            _buildStatItem('الإجمالي', '$totalStudents', Icons.people),
            _buildStatItem('النسبة', '${submissionRate}%', Icons.percent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ColorsApp.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(value, style: font16blackbold),
        Text(label, style: font12Grey),
      ],
    );
  }

  Widget _buildSubmissionsList() {
    final submissions = widget.homework.students.where((s) => s.isSubmitted).toList();

    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late, size: 80, color: ColorsApp.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد تسليمات بعد',
              style: font18blackbold,
            ),
            const SizedBox(height: 8),
            Text(
              'لم يقم أي طالب بتسليم الواجب حتى الآن',
              style: font16Grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return _buildSubmissionCard(submission);
      },
    );
  }

  Widget _buildSubmissionCard(StudentHomeworkModel submission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطالب
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.name,
                        style: font16blackbold,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رقم القيد: ${submission.idStudent}',
                        style: font12Grey,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: submission.isGraded ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    submission.isGraded ? 'مقيم' : 'بانتظار التقييم',
                    style: font11White,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // معلومات التسليم
            if (submission.title.isNotEmpty) ...[
              Text(
                'عنوان التسليم: ${submission.title}',
                style: font14black,
              ),
              const SizedBox(height: 8),
            ],
            
            if (submission.submitTime != null) 
              Text(
                'وقت التسليم: ${_formatDateTime(submission.submitTime!)}',
                style: font12Grey,
              ),
            
            const SizedBox(height: 12),
            
            // التقييم والتحميل
            Row(
              children: [
                // حقل التقييم
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الدرجة (من ${widget.homework.maxMark})',
                      border: const OutlineInputBorder(),
                      suffixText: '/${widget.homework.maxMark}',
                    ),
                    onChanged: (value) {
                      final grade = double.tryParse(value) ?? 0;
                      if (grade <= widget.homework.maxMark) {
                        _gradingValues[submission.idStudent] = grade;
                      }
                    },
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // زر فتح الملف
                if (submission.file.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openSubmissionFile(submission.file),
                    icon: const Icon(Icons.file_open, color: Colors.white),
                    label: const Text('فتح', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsApp.primaryColor,
                    ),
                  ),
              ],
            ),
            
            // الدرجة الحالية إن وجدت
            if (submission.isGraded) ...[
              const SizedBox(height: 8),
              Text(
                'الدرجة الحالية: ${submission.fromMark}/${widget.homework.maxMark}',
                style: font14black.copyWith(
                  color: ColorsApp.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openSubmissionFile(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن فتح الرابط: $fileUrl'),
          backgroundColor: ColorsApp.red,
        ),
      );
    }
  }

  Future<void> _saveAllGrades() async {
    if (_gradingValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لم تقم بإدخال أي درجات'),
          backgroundColor: ColorsApp.orange,
        ),
      );
      return;
    }

      await CustomDialog.showConfirmation(
      context: context,
      title: 'حفظ الدرجات',
      message: 'سيتم حفظ ${_gradingValues.length} درجة',
      confirmText: 'حفظ الكل',
      cancelText: 'إلغاء',
    );

    int savedCount = 0;
  for (final entry in _gradingValues.entries) {
    try {
      context.read<SubjectiveBloc>().add(
        GradeHomeworkEvent(
          courseId: widget.course.id,
          groupId: widget.group.id,
          homeworkId: widget.homework.id,
          studentId: entry.key,
          mark: entry.value,
        ),
      );
      savedCount++;
    } catch (e) {
      print('❌ خطأ في حفظ درجة الطالب ${entry.key}: $e');
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تم حفظ $savedCount درجة بنجاح'),
      backgroundColor: ColorsApp.green,
    ),
  );
  
  // إعادة تحميل البيانات بعد الحفظ
  _gradingValues.clear();
  Future.delayed(const Duration(milliseconds: 500), () {
    setState(() {});
  });
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}