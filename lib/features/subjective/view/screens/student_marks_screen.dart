import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class StudentMarksScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final String userId;

  const StudentMarksScreen({
    super.key,
    required this.course,
    required this.group,
    required this.userId,
  });

  @override
  State<StudentMarksScreen> createState() => _StudentMarksScreenState();
}

class _StudentMarksScreenState extends State<StudentMarksScreen> {
  @override
  void initState() {
    super.initState();
    _loadStudentGrades();
  }

  void _loadStudentGrades() {
    context.read<SubjectiveBloc>().add(
      LoadExamGradesEvent(
        courseId: widget.course.id,
        groupId: widget.group.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.codeCs, style: TextStyle(fontSize: 14)),
            Text('الدرجات - ${widget.course.name}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: BlocBuilder<SubjectiveBloc, SubjectiveState>(
        builder: (context, state) {
          if (state is SubjectiveLoading) {
            return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
          }

          if (state is SubjectiveError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: ColorsApp.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: font16black,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is ExamGradesLoadSuccess) {
            final studentGrades = state.examGrades
                .where((grade) => grade.studentId == widget.userId)
                .toList();

            return _buildStudentGrades(studentGrades);
          }

          return const Center(child: Text('جاري تحميل البيانات...'));
        },
      ),
    );
  }

  Widget _buildStudentGrades(List<ExamGradeModel> grades) {
    if (grades.isEmpty) {
      return _buildEmptyGrades();
    }

    return RefreshIndicator(
      color: ColorsApp.primaryColor,
      onRefresh: () async {
        _loadStudentGrades();
      },
      child: Column(
        children: [
          // بطاقة الملخص
          _buildSummaryCard(grades),
          const SizedBox(height: 16),
          // قائمة الدرجات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              itemBuilder: (context, index) => _buildGradeCard(grades[index]),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyGrades() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade, size: 80, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد درجات مسجلة',
            style: font18blackbold,
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم عرض درجاتك هنا عندما يتم تقييمها',
            style: font16Grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<ExamGradeModel> grades) {
    final total = grades.fold(0.0, (sum, grade) => sum + grade.grade);
    final maxTotal = grades.fold(0.0, (sum, grade) => sum + grade.maxGrade);
    final double percentage = maxTotal > 0 ? (total / maxTotal * 100) : 0;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'ملخص الدرجات',
              style: font20blackbold,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('المجموع', '${total.toStringAsFixed(1)}', Icons.summarize),
                _buildSummaryItem('النسبة', '${percentage.toStringAsFixed(1)}%', Icons.percent),
                _buildSummaryItem('عدد الاختبارات', '${grades.length}', Icons.assignment),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getGradeColor(percentage)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ColorsApp.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(value, style: font16blackbold),
        Text(label, style: font12Grey),
      ],
    );
  }

  Widget _buildGradeCard(ExamGradeModel grade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  grade.examType,
                  style: font16blackbold,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade.percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getGradeColor(grade.percentage)),
                  ),
                  child: Text(
                    '${grade.percentage.toStringAsFixed(1)}%',
                    style: font12black.copyWith(
                      color: _getGradeColor(grade.percentage),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الدرجة: ${grade.grade}/${grade.maxGrade}', style: font14black),
                Text('التاريخ: ${_formatDate(grade.examDate)}', style: font12Grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}