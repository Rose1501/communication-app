import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/components/themeData/colors_app.dart';
import 'package:myproject/components/themeData/text_style.dart';
import 'package:myproject/components/widget/onlyTitleAppBar.dart';
import 'package:myproject/features/subjective/bloc/subjective_bloc.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

class MarksScreen extends StatefulWidget {
  final CoursesModel course;
  final GroupModel group;
  final String userRole;
  final String userId;

  const MarksScreen({
    super.key,
    required this.course,
    required this.group,
    required this.userRole,
    required this.userId,
  });

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  List<ExamGradeModel> _allGrades = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMarksData();
  }

  void _loadMarksData() {
    setState(() {
      _isLoading = true;
    });

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
      appBar: CustomAppBarTitle(
        title: '${widget.course.name} - الدرجات',
      ),
      body: BlocConsumer<SubjectiveBloc, SubjectiveState>(
        listener: (context, state) {
          if (state is ExamGradesLoadSuccess) {
            setState(() {
              _isLoading = false;
              _allGrades = state.examGrades;
            });
          }
          
          if (state is SubjectiveError) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return  Center(child: CircularProgressIndicator(color: ColorsApp.primaryColor,));
          }

          if (state is SubjectiveError) {
            return _buildErrorState(state.message);
          }

          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    if (widget.userRole == 'Doctor') {
      return _buildDoctorView();
    } else {
      return _buildStudentView();
    }
  }

  // ========== عرض الدكتور (جميع درجات الطلاب) ==========

  Widget _buildDoctorView() {
    if (_allGrades.isEmpty) {
      return _buildEmptyGradesState('لا توجد درجات مسجلة بعد');
    }

    return Column(
      children: [
        // إحصائيات سريعة
        _buildDoctorStatistics(),
        const SizedBox(height: 16),
        // جدول جميع الطلاب
        Expanded(
          child: _buildAllStudentsTable(),
        ),
      ],
    );
  }

  Widget _buildDoctorStatistics() {
    final totalStudents = widget.group.students.length;
    final gradedStudents = _getGradedStudentsCount();
    final average = _calculateOverallAverage();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsApp.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي الطلاب', '$totalStudents', Icons.people),
          _buildStatItem('تم التقييم', '$gradedStudents', Icons.assignment_turned_in),
          _buildStatItem('المعدل العام', '${average.toStringAsFixed(1)}%', Icons.analytics),
        ],
      ),
    );
  }

  Widget _buildAllStudentsTable() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(ColorsApp.primaryColor.withOpacity(0.1)),
            columns: _buildDoctorTableColumns(),
            rows: widget.group.students.map((student) => _buildStudentRow(student)).toList(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildDoctorTableColumns() {
    // استخراج أنواع الامتحانات المختلفة
    final examTypes = _allGrades.map((g) => g.examType).toSet().toList();
    
    final columns = <DataColumn>[
      const DataColumn(label: Text('م')),
      const DataColumn(label: Text('اسم الطالب')),
      const DataColumn(label: Text('رقم القيد')),
      ...examTypes.map((type) => DataColumn(
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type, style: font12black.copyWith(fontWeight: FontWeight.bold)),
            Text('${_getMaxGradeForType(type)}', style: font12Grey),
          ],
        ),
      )),
      const DataColumn(label: Text('المجموع')),
      const DataColumn(label: Text('النسبة')),
    ];

    return columns;
  }

  DataRow _buildStudentRow(StudentModel student) {
    final studentGrades = _allGrades.where((grade) => grade.studentId == student.id).toList();
    final examTypes = _allGrades.map((g) => g.examType).toSet().toList();
    
    double total = 0.0;
    double maxTotal = 0.0;

    // حساب المجموع والدرجة القصوى
    for (final type in examTypes) {
      final grade = studentGrades.firstWhere(
        (g) => g.examType == type,
        orElse: () => ExamGradeModel.empty,
      );
      total += grade.grade;
      maxTotal += grade.maxGrade;
    }

    final percentage = maxTotal > 0 ? (total / maxTotal * 100) : 0.0;

    return DataRow(
      cells: [
        DataCell(Text((widget.group.students.indexOf(student) + 1).toString())),
        DataCell(
          Tooltip(
            message: student.name,
            child: Text(
              student.name,
              style: font12black,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(student.studentId, style: font12black)),
        ...examTypes.map((type) {
          final grade = studentGrades.firstWhere(
            (g) => g.examType == type,
            orElse: () => ExamGradeModel.empty,
          );
          return DataCell(
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                grade.grade > 0 ? grade.grade.toStringAsFixed(1) : '-',
                style: font12black.copyWith(
                  color: grade.grade > 0 ? _getGradeColor(grade.grade, grade.maxGrade) : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
        DataCell(
          Text(
            total > 0 ? total.toStringAsFixed(1) : '-',
            style: font12black.copyWith(
              fontWeight: FontWeight.bold,
              color: total > 0 ? _getTotalColor(total, maxTotal) : Colors.grey,
            ),
          ),
        ),
        DataCell(
          Text(
            percentage > 0 ? '${percentage.toStringAsFixed(1)}%' : '-',
            style: font12black.copyWith(
              fontWeight: FontWeight.bold,
              color: percentage > 0 ? _getPercentageColor(percentage) : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // ========== عرض الطالب (درجاته فقط) ==========

  Widget _buildStudentView() {
    final studentGrades = _allGrades
        .where((grade) => grade.studentId == widget.userId)
        .toList();

    if (studentGrades.isEmpty) {
      return _buildEmptyGradesState('لا توجد درجات مسجلة لك بعد');
    }

    return RefreshIndicator(
      color: ColorsApp.primaryColor,
      onRefresh: () async {
        _loadMarksData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStudentSummaryCard(studentGrades),
          const SizedBox(height: 20),
          ...studentGrades.map(_buildStudentGradeCard).toList(),
        ],
      ),
    );
  }

  Widget _buildStudentSummaryCard(List<ExamGradeModel> grades) {
    final total = grades.fold(0.0, (sum, grade) => sum + grade.grade);
    final maxTotal = grades.fold(0.0, (sum, grade) => sum + grade.maxGrade);
    final percentage = maxTotal > 0 ? (total / maxTotal * 100) : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'ملخص درجاتك',
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
              valueColor: AlwaysStoppedAnimation<Color>(_getPercentageColor(percentage)),
            ),
            const SizedBox(height: 8),
            Text(
              'التقدير: ${_getGradeEstimation(percentage)}',
              style: font14black.copyWith(
                fontWeight: FontWeight.bold,
                color: _getPercentageColor(percentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentGradeCard(ExamGradeModel grade) {
    final percentage = (grade.grade / grade.maxGrade) * 100;

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
                    color: _getPercentageColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getPercentageColor(percentage)),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: font12black.copyWith(
                      color: _getPercentageColor(percentage),
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
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getPercentageColor(percentage)),
            ),
          ],
        ),
      ),
    );
  }

  // ========== دوال مساعدة ==========

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: ColorsApp.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: font16black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadMarksData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGradesState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade, size: 80, color: ColorsApp.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: font18blackbold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (widget.userRole == 'Doctor')
            Text(
              'يمكنك إضافة الدرجات من خلال زر الإضافة',
              style: font16Grey,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(value, style: font16White.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: font11White),
      ],
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

  // ========== دوال حسابية ==========

  int _getGradedStudentsCount() {
    final gradedStudents = <String>{};
    for (final grade in _allGrades) {
      if (grade.grade > 0) {
        gradedStudents.add(grade.studentId);
      }
    }
    return gradedStudents.length;
  }

  double _calculateOverallAverage() {
    if (_allGrades.isEmpty) return 0.0;
    
    double total = 0.0;
    int count = 0;
    
    for (final grade in _allGrades) {
      if (grade.grade > 0) {
        total += (grade.grade / grade.maxGrade) * 100;
        count++;
      }
    }
    
    return count > 0 ? total / count : 0.0;
  }

  double _getMaxGradeForType(String examType) {
    final grade = _allGrades.firstWhere(
      (g) => g.examType == examType,
      orElse: () => ExamGradeModel.empty,
    );
    return grade.maxGrade;
  }

  String _getGradeEstimation(double percentage) {
    if (percentage >= 95) return 'امتياز';
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 85) return 'جيد جداً';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 75) return 'جيد';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 65) return 'مقبول';
    if (percentage >= 60) return 'مقبول';
    return 'راسب';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ========== دوال الألوان ==========

  Color _getGradeColor(double grade, double maxGrade) {
    final percentage = (grade / maxGrade) * 100;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }

  Color _getTotalColor(double total, double maxTotal) {
    final percentage = (total / maxTotal) * 100;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.amber;
    return Colors.red;
  }
}